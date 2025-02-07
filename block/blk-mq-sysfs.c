#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/backing-dev.h>
#include <linux/bio.h>
#include <linux/blkdev.h>
#include <linux/mm.h>
#include <linux/init.h>
#include <linux/slab.h>
#include <linux/workqueue.h>
#include <linux/smp.h>

#include <linux/blk-mq.h>
#include "blk-mq.h"
#include "blk-mq-tag.h"

static void blk_mq_sysfs_release(struct kobject *kobj)
{
}

struct blk_mq_ctx_sysfs_entry {
	struct attribute attr;
	ssize_t (*show)(struct blk_mq_ctx *, char *);
	ssize_t (*store)(struct blk_mq_ctx *, const char *, size_t);
};

struct blk_mq_hw_ctx_sysfs_entry {
	struct attribute attr;
	ssize_t (*show)(struct blk_mq_hw_ctx *, char *);
	ssize_t (*store)(struct blk_mq_hw_ctx *, const char *, size_t);
};

static ssize_t blk_mq_sysfs_show(struct kobject *kobj, struct attribute *attr,
				 char *page)
{
	struct blk_mq_ctx_sysfs_entry *entry;
	struct blk_mq_ctx *ctx;
	struct request_queue *q;
	ssize_t res;

	entry = container_of(attr, struct blk_mq_ctx_sysfs_entry, attr);
	ctx = container_of(kobj, struct blk_mq_ctx, kobj);
	q = ctx->queue;

	if (!entry->show)
		return -EIO;

	res = -ENOENT;
	mutex_lock(&q->sysfs_lock);
	if (!blk_queue_dying(q))
		res = entry->show(ctx, page);
	mutex_unlock(&q->sysfs_lock);
	return res;
}

static ssize_t blk_mq_sysfs_store(struct kobject *kobj, struct attribute *attr,
				  const char *page, size_t length)
{
	struct blk_mq_ctx_sysfs_entry *entry;
	struct blk_mq_ctx *ctx;
	struct request_queue *q;
	ssize_t res;

	entry = container_of(attr, struct blk_mq_ctx_sysfs_entry, attr);
	ctx = container_of(kobj, struct blk_mq_ctx, kobj);
	q = ctx->queue;

	if (!entry->store)
		return -EIO;

	res = -ENOENT;
	mutex_lock(&q->sysfs_lock);
	if (!blk_queue_dying(q))
		res = entry->store(ctx, page, length);
	mutex_unlock(&q->sysfs_lock);
	return res;
}

static ssize_t blk_mq_hw_sysfs_show(struct kobject *kobj,
				    struct attribute *attr, char *page)
{
	struct blk_mq_hw_ctx_sysfs_entry *entry;
	struct blk_mq_hw_ctx *hctx;
	struct request_queue *q;
	ssize_t res;

	entry = container_of(attr, struct blk_mq_hw_ctx_sysfs_entry, attr);
	hctx = container_of(kobj, struct blk_mq_hw_ctx, kobj);
	q = hctx->queue;

	if (!entry->show)
		return -EIO;

	res = -ENOENT;
	mutex_lock(&q->sysfs_lock);
	if (!blk_queue_dying(q))
		res = entry->show(hctx, page);
	mutex_unlock(&q->sysfs_lock);
	return res;
}

static ssize_t blk_mq_hw_sysfs_store(struct kobject *kobj,
				     struct attribute *attr, const char *page,
				     size_t length)
{
	struct blk_mq_hw_ctx_sysfs_entry *entry;
	struct blk_mq_hw_ctx *hctx;
	struct request_queue *q;
	ssize_t res;

	entry = container_of(attr, struct blk_mq_hw_ctx_sysfs_entry, attr);
	hctx = container_of(kobj, struct blk_mq_hw_ctx, kobj);
	q = hctx->queue;

	if (!entry->store)
		return -EIO;

	res = -ENOENT;
	mutex_lock(&q->sysfs_lock);
	if (!blk_queue_dying(q))
		res = entry->store(hctx, page, length);
	mutex_unlock(&q->sysfs_lock);
	return res;
}

static ssize_t blk_mq_hw_sysfs_nr_tags_show(struct blk_mq_hw_ctx *hctx,
					    char *page)
{
	return sprintf(page, "%u\n", hctx->tags->nr_tags);
}

static ssize_t blk_mq_hw_sysfs_nr_reserved_tags_show(struct blk_mq_hw_ctx *hctx,
						     char *page)
{
	return sprintf(page, "%u\n", hctx->tags->nr_reserved_tags);
}

static ssize_t blk_mq_hw_sysfs_cpus_show(struct blk_mq_hw_ctx *hctx, char *page)
{
	const size_t size = PAGE_SIZE - 1;
	unsigned int i, first = 1;
	int ret = 0, pos = 0;

	for_each_cpu(i, hctx->cpumask) {
		if (first)
			ret = snprintf(pos + page, size - pos, "%u", i);
		else
			ret = snprintf(pos + page, size - pos, ", %u", i);

		if (ret >= size - pos)
			break;

		first = 0;
		pos += ret;
	}

	ret = snprintf(pos + page, size + 1 - pos, "\n");
	return pos + ret;
}

static struct attribute *default_ctx_attrs[] = {
	NULL,
};

static struct blk_mq_hw_ctx_sysfs_entry blk_mq_hw_sysfs_nr_tags = {
	.attr = {.name = "nr_tags", .mode = S_IRUGO },
	.show = blk_mq_hw_sysfs_nr_tags_show,
};
static struct blk_mq_hw_ctx_sysfs_entry blk_mq_hw_sysfs_nr_reserved_tags = {
	.attr = {.name = "nr_reserved_tags", .mode = S_IRUGO },
	.show = blk_mq_hw_sysfs_nr_reserved_tags_show,
};
static struct blk_mq_hw_ctx_sysfs_entry blk_mq_hw_sysfs_cpus = {
	.attr = {.name = "cpu_list", .mode = S_IRUGO },
	.show = blk_mq_hw_sysfs_cpus_show,
};

static struct attribute *default_hw_ctx_attrs[] = {
	&blk_mq_hw_sysfs_nr_tags.attr,
	&blk_mq_hw_sysfs_nr_reserved_tags.attr,
	&blk_mq_hw_sysfs_cpus.attr,
	NULL,
};

static const struct sysfs_ops blk_mq_sysfs_ops = {
	.show	= blk_mq_sysfs_show,
	.store	= blk_mq_sysfs_store,
};

static const struct sysfs_ops blk_mq_hw_sysfs_ops = {
	.show	= blk_mq_hw_sysfs_show,
	.store	= blk_mq_hw_sysfs_store,
};

static struct kobj_type blk_mq_ktype = {
	.sysfs_ops	= &blk_mq_sysfs_ops,
	.release	= blk_mq_sysfs_release,
};

static struct kobj_type blk_mq_ctx_ktype = {
	.sysfs_ops	= &blk_mq_sysfs_ops,
	.default_attrs	= default_ctx_attrs,
	.release	= blk_mq_sysfs_release,
};

static struct kobj_type blk_mq_hw_ktype = {
	.sysfs_ops	= &blk_mq_hw_sysfs_ops,
	.default_attrs	= default_hw_ctx_attrs,
	.release	= blk_mq_sysfs_release,
};

static void blk_mq_unregister_hctx(struct blk_mq_hw_ctx *hctx)
{
	struct blk_mq_ctx *ctx;
	int i;

	if (!hctx->nr_ctx)
		return;

	hctx_for_each_ctx(hctx, ctx, i)
		kobject_del(&ctx->kobj);

	kobject_del(&hctx->kobj);
}

static int blk_mq_register_hctx(struct blk_mq_hw_ctx *hctx)
{
	struct request_queue *q = hctx->queue;
	struct blk_mq_ctx *ctx;
	int i, j, ret;

	if (!hctx->nr_ctx)
		return 0;

	ret = kobject_add(&hctx->kobj, &q->mq_kobj, "%u", hctx->queue_num);
	if (ret)
		return ret;

	hctx_for_each_ctx(hctx, ctx, i) {
		ret = kobject_add(&ctx->kobj, &hctx->kobj, "cpu%u", ctx->cpu);
		if (ret)
			goto out;
	}

	return 0;
out:
	hctx_for_each_ctx(hctx, ctx, j) {
		if (j < i)
			kobject_del(&ctx->kobj);
	}
	kobject_del(&hctx->kobj);
	return ret;
}

static void __blk_mq_unregister_dev(struct device *dev, struct request_queue *q)
{
	struct blk_mq_hw_ctx *hctx;
	struct blk_mq_ctx *ctx;
	int i, j;

#ifdef CONFIG_EXYNOS_HOTPLUG_GOVERNOR
	lockdep_assert_held(&q->sysfs_lock);
#endif

	queue_for_each_hw_ctx(q, hctx, i) {
		blk_mq_unregister_hctx(hctx);

		hctx_for_each_ctx(hctx, ctx, j)
			kobject_put(&ctx->kobj);

		kobject_put(&hctx->kobj);
	}

	blk_mq_debugfs_unregister(q);

	kobject_uevent(&q->mq_kobj, KOBJ_REMOVE);
	kobject_del(&q->mq_kobj);
	kobject_put(&q->mq_kobj);

	kobject_put(&dev->kobj);

	q->mq_sysfs_init_done = false;
}

void blk_mq_unregister_dev(struct device *dev, struct request_queue *q)
{
#ifdef CONFIG_EXYNOS_HOTPLUG_GOVERNOR
	mutex_lock(&q->sysfs_lock);
#else
	blk_mq_disable_hotplug();
#endif
	__blk_mq_unregister_dev(dev, q);
#ifdef CONFIG_EXYNOS_HOTPLUG_GOVERNOR
	mutex_unlock(&q->sysfs_lock);
#else
	blk_mq_enable_hotplug();
#endif
}

void blk_mq_hctx_kobj_init(struct blk_mq_hw_ctx *hctx)
{
	kobject_init(&hctx->kobj, &blk_mq_hw_ktype);
}

void blk_mq_sysfs_init(struct request_queue *q)
{
	struct blk_mq_ctx *ctx;
	int cpu;

	kobject_init(&q->mq_kobj, &blk_mq_ktype);

	for_each_possible_cpu(cpu) {
		ctx = per_cpu_ptr(q->queue_ctx, cpu);
		kobject_init(&ctx->kobj, &blk_mq_ctx_ktype);
	}
}
#ifdef CONFIG_EXYNOS_HOTPLUG_GOVERNOR
int __blk_mq_register_dev(struct device *dev, struct request_queue *q)
#else
int blk_mq_register_dev(struct device *dev, struct request_queue *q)
#endif
{
	struct blk_mq_hw_ctx *hctx;
	int ret, i;

#ifdef CONFIG_EXYNOS_HOTPLUG_GOVERNOR
	WARN_ON_ONCE(!q->kobj.parent);
	lockdep_assert_held(&q->sysfs_lock);
#else
	blk_mq_disable_hotplug();
#endif

	ret = kobject_add(&q->mq_kobj, kobject_get(&dev->kobj), "%s", "mq");
	if (ret < 0)
		goto out;

	kobject_uevent(&q->mq_kobj, KOBJ_ADD);

	blk_mq_debugfs_register(q, kobject_name(&dev->kobj));

	queue_for_each_hw_ctx(q, hctx, i) {
		ret = blk_mq_register_hctx(hctx);
		if (ret)
			break;
	}

	if (ret)
		__blk_mq_unregister_dev(dev, q);
	else
		q->mq_sysfs_init_done = true;
out:
#ifndef CONFIG_EXYNOS_HOTPLUG_GOVERNOR
	blk_mq_enable_hotplug();
#endif

	return ret;
}
EXPORT_SYMBOL_GPL(blk_mq_register_dev);

#ifdef CONFIG_EXYNOS_HOTPLUG_GOVERNOR
int blk_mq_register_dev(struct device *dev, struct request_queue *q)
{
	int ret;

	mutex_lock(&q->sysfs_lock);
	ret = __blk_mq_register_dev(dev, q);
	mutex_unlock(&q->sysfs_lock);

	return ret;
}
#endif

void blk_mq_sysfs_unregister(struct request_queue *q)
{
	struct blk_mq_hw_ctx *hctx;
	int i;

#ifdef CONFIG_EXYNOS_HOTPLUG_GOVERNOR
	mutex_lock(&q->sysfs_lock);
#endif
	if (!q->mq_sysfs_init_done)
#ifdef CONFIG_EXYNOS_HOTPLUG_GOVERNOR
		goto unlock;
#endif
		return;

	blk_mq_debugfs_unregister_hctxs(q);

	queue_for_each_hw_ctx(q, hctx, i)
		blk_mq_unregister_hctx(hctx);

#ifdef CONFIG_EXYNOS_HOTPLUG_GOVERNOR
unlock:
	mutex_unlock(&q->sysfs_lock);
#endif
}

int blk_mq_sysfs_register(struct request_queue *q)
{
	struct blk_mq_hw_ctx *hctx;
	int i, ret = 0;

#ifdef CONFIG_EXYNOS_HOTPLUG_GOVERNOR
	mutex_lock(&q->sysfs_lock);
#endif
	if (!q->mq_sysfs_init_done)
#ifdef CONFIG_EXYNOS_HOTPLUG_GOVERNOR
		goto unlock;
#else
		return ret;
#endif

	blk_mq_debugfs_register_hctxs(q);

	queue_for_each_hw_ctx(q, hctx, i) {
		ret = blk_mq_register_hctx(hctx);
		if (ret)
			break;
	}

#ifdef CONFIG_EXYNOS_HOTPLUG_GOVERNOR
unlock:
	mutex_unlock(&q->sysfs_lock);
	return ret;
#else
	return ret;
#endif
}
