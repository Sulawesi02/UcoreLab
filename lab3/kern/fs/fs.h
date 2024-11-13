#ifndef __KERN_FS_FS_H__
#define __KERN_FS_FS_H__

#include <mmu.h>

#define SECTSIZE            512 // 磁盘扇区大小
#define PAGE_NSECT          (PGSIZE / SECTSIZE) //一页需要4096/512=8个磁盘扇区?

#define SWAP_DEV_NO         1

#endif /* !__KERN_FS_FS_H__ */

