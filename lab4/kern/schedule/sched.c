#include <list.h>
#include <sync.h>
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
    proc->state = PROC_RUNNABLE;
}

// 进程调度与进程切换
void
schedule(void) {
    bool intr_flag;// 保存当前中断状态，确保在调度期间中段禁用，避免调度被打断
    list_entry_t *le, *last;// 进程链表迭代器，分别用于遍历进程和保存当前进程位置
    struct proc_struct *next = NULL;// 指向下一个要运行的进程

    // 保存当前中断状态，并禁止中断
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;// 表示当前进程不需被重新调度
        // 判断当前进程是否为空闲进程，是则从头遍历，否则从当前遍历
        last = (current == idleproc) ? &proc_list : &(current->list_link);
        le = last;
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
                    break;
                }
            }
        } while (le != last);
        // 若未找到，则将next设为空闲进程，保证系统不会无进程可运行
        if (next == NULL || next->state != PROC_RUNNABLE) {
            next = idleproc;
        }
        // 上下文切换
        next->runs ++;// 选中进程的运行次数+1
        //若选中进程不是当前运行进程，则调用 proc_run(next) 进行上下文切换，切换到 next。
        if (next != current) {
            proc_run(next);
        }
    }
    local_intr_restore(intr_flag);// 恢复中断
}


