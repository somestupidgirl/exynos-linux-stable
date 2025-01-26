#ifndef _ASM_ARM_TOPOLOGY_H
#define _ASM_ARM_TOPOLOGY_H

#ifdef CONFIG_ARM_CPU_TOPOLOGY

#include <linux/cpufreq.h>
#include <linux/cpumask.h>

struct cputopo_arm {
	int thread_id;
	int core_id;
	int socket_id;
	cpumask_t thread_sibling;
	cpumask_t core_sibling;
};

extern struct cputopo_arm cpu_topology[NR_CPUS];

#define topology_physical_package_id(cpu)	(cpu_topology[cpu].socket_id)
#define topology_core_id(cpu)		(cpu_topology[cpu].core_id)
#define topology_core_cpumask(cpu)	(&cpu_topology[cpu].core_sibling)
#define topology_sibling_cpumask(cpu)	(&cpu_topology[cpu].thread_sibling)

void init_cpu_topology(void);
void store_cpu_topology(unsigned int cpuid);
const struct cpumask *cpu_coregroup_mask(int cpu);

#ifdef CONFIG_DISABLE_CPU_SCHED_DOMAIN_BALANCE
/* Common values for CPUs */
#ifndef SD_CPU_INIT
#define SD_CPU_INIT (struct sched_domain) { \
	.min_interval = 1, \
	.max_interval = 4, \
	.busy_factor = 64, \
	.imbalance_pct = 125, \
	.cache_nice_tries = 1, \
	.busy_idx = 2, \
	.idle_idx = 1, \
	.newidle_idx = 0, \
	.wake_idx = 0, \
	.forkexec_idx = 0, \
	\
	.flags = 0*SD_LOAD_BALANCE \
	| 1*SD_BALANCE_NEWIDLE \
	| 1*SD_BALANCE_EXEC \
	| 1*SD_BALANCE_FORK \
	| 0*SD_BALANCE_WAKE \
	| 1*SD_WAKE_AFFINE \
	| 0*SD_PREFER_LOCAL \
	| 0*SD_SHARE_CPUPOWER \
	| 0*SD_SHARE_PKG_RESOURCES \
	| 0*SD_SERIALIZE \
	, \
	.last_balance = jiffies, \
	.balance_interval = 1, \
}
#endif
#endif /* CONFIG_DISABLE_CPU_SCHED_DOMAIN_BALANCE */

#ifdef CONFIG_CPU_FREQ
#define arch_scale_freq_capacity cpufreq_scale_freq_capacity
#define arch_scale_max_freq_capacity cpufreq_scale_max_freq_capacity
#define arch_scale_min_freq_capacity cpufreq_scale_min_freq_capacity
#endif
#define arch_scale_cpu_capacity scale_cpu_capacity
extern unsigned long scale_cpu_capacity(struct sched_domain *sd, int cpu);

#else

static inline void init_cpu_topology(void) { }
static inline void store_cpu_topology(unsigned int cpuid) { }

#endif

#include <asm-generic/topology.h>

#endif /* _ASM_ARM_TOPOLOGY_H */
