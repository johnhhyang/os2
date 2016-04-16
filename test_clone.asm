
_test_clone:     file format elf32-i386


Disassembly of section .text:

00000000 <thread>:

#define NUM_THREADS 16
#define TARGET_COUNT_PER_THREAD 100000

void *thread(void *arg)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
	int i;
	int counter;

	sleep(10);
   6:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
   d:	e8 fa 05 00 00       	call   60c <sleep>
	printf(1, "thread %d: started...\n", *(int*)arg);
  12:	8b 45 08             	mov    0x8(%ebp),%eax
  15:	8b 00                	mov    (%eax),%eax
  17:	89 44 24 08          	mov    %eax,0x8(%esp)
  1b:	c7 44 24 04 d8 0a 00 	movl   $0xad8,0x4(%esp)
  22:	00 
  23:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  2a:	e8 e4 06 00 00       	call   713 <printf>

	for (i=0; i<TARGET_COUNT_PER_THREAD; i++) {
  2f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  36:	eb 20                	jmp    58 <thread+0x58>
		sleep(0);
  38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  3f:	e8 c8 05 00 00       	call   60c <sleep>
		counter++;
  44:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
		sleep(0);
  48:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  4f:	e8 b8 05 00 00       	call   60c <sleep>
	int counter;

	sleep(10);
	printf(1, "thread %d: started...\n", *(int*)arg);

	for (i=0; i<TARGET_COUNT_PER_THREAD; i++) {
  54:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  58:	81 7d f4 9f 86 01 00 	cmpl   $0x1869f,-0xc(%ebp)
  5f:	7e d7                	jle    38 <thread+0x38>
		sleep(0);
		counter++;
		sleep(0);
	}

	texit(arg);
  61:	8b 45 08             	mov    0x8(%ebp),%eax
  64:	89 04 24             	mov    %eax,(%esp)
  67:	e8 c8 05 00 00       	call   634 <texit>
}
  6c:	c9                   	leave  
  6d:	c3                   	ret    

0000006e <main>:

int main(int argc, char **argv)
{
  6e:	55                   	push   %ebp
  6f:	89 e5                	mov    %esp,%ebp
  71:	83 e4 f0             	and    $0xfffffff0,%esp
  74:	81 ec f0 00 00 00    	sub    $0xf0,%esp
	int i;
	int passed = 1;
  7a:	c7 84 24 e8 00 00 00 	movl   $0x1,0xe8(%esp)
  81:	01 00 00 00 
	// Args
	int *args[NUM_THREADS];

	// Allocate stacks and args and make sure we have them all
	// Bail if something fails
	for (i=0; i<NUM_THREADS; i++) {
  85:	c7 84 24 ec 00 00 00 	movl   $0x0,0xec(%esp)
  8c:	00 00 00 00 
  90:	e9 9a 00 00 00       	jmp    12f <main+0xc1>
		stacks[i] = (void*) malloc(4096);
  95:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  9c:	e8 56 09 00 00       	call   9f7 <malloc>
  a1:	8b 94 24 ec 00 00 00 	mov    0xec(%esp),%edx
  a8:	89 44 94 64          	mov    %eax,0x64(%esp,%edx,4)
		if (!stacks[i]) {
  ac:	8b 84 24 ec 00 00 00 	mov    0xec(%esp),%eax
  b3:	8b 44 84 64          	mov    0x64(%esp,%eax,4),%eax
  b7:	85 c0                	test   %eax,%eax
  b9:	75 19                	jne    d4 <main+0x66>
			printf(1, "main: could not get stack for thread %d, exiting...\n");
  bb:	c7 44 24 04 f0 0a 00 	movl   $0xaf0,0x4(%esp)
  c2:	00 
  c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  ca:	e8 44 06 00 00       	call   713 <printf>
			exit();
  cf:	e8 a8 04 00 00       	call   57c <exit>
		}

		args[i] = (int*) malloc(sizeof(int));
  d4:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  db:	e8 17 09 00 00       	call   9f7 <malloc>
  e0:	8b 94 24 ec 00 00 00 	mov    0xec(%esp),%edx
  e7:	89 44 94 24          	mov    %eax,0x24(%esp,%edx,4)
		if (!args[i]) {
  eb:	8b 84 24 ec 00 00 00 	mov    0xec(%esp),%eax
  f2:	8b 44 84 24          	mov    0x24(%esp,%eax,4),%eax
  f6:	85 c0                	test   %eax,%eax
  f8:	75 19                	jne    113 <main+0xa5>
			printf(1, "main: could not get memory (for arg) for thread %d, exiting...\n");
  fa:	c7 44 24 04 28 0b 00 	movl   $0xb28,0x4(%esp)
 101:	00 
 102:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 109:	e8 05 06 00 00       	call   713 <printf>
			exit();
 10e:	e8 69 04 00 00       	call   57c <exit>
		}

		*args[i] = i;
 113:	8b 84 24 ec 00 00 00 	mov    0xec(%esp),%eax
 11a:	8b 44 84 24          	mov    0x24(%esp,%eax,4),%eax
 11e:	8b 94 24 ec 00 00 00 	mov    0xec(%esp),%edx
 125:	89 10                	mov    %edx,(%eax)
	// Args
	int *args[NUM_THREADS];

	// Allocate stacks and args and make sure we have them all
	// Bail if something fails
	for (i=0; i<NUM_THREADS; i++) {
 127:	83 84 24 ec 00 00 00 	addl   $0x1,0xec(%esp)
 12e:	01 
 12f:	83 bc 24 ec 00 00 00 	cmpl   $0xf,0xec(%esp)
 136:	0f 
 137:	0f 8e 58 ff ff ff    	jle    95 <main+0x27>
		}

		*args[i] = i;
	}

	printf(1, "main: running with %d threads...\n", NUM_THREADS);
 13d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 144:	00 
 145:	c7 44 24 04 68 0b 00 	movl   $0xb68,0x4(%esp)
 14c:	00 
 14d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 154:	e8 ba 05 00 00       	call   713 <printf>

	// Start all children
	for (i=0; i<NUM_THREADS; i++) {
 159:	c7 84 24 ec 00 00 00 	movl   $0x0,0xec(%esp)
 160:	00 00 00 00 
 164:	eb 7a                	jmp    1e0 <main+0x172>
		printf(1, "Clone is being called in test_clone.c\n");
 166:	c7 44 24 04 8c 0b 00 	movl   $0xb8c,0x4(%esp)
 16d:	00 
 16e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 175:	e8 99 05 00 00       	call   713 <printf>
		pids[i] = clone(thread, args[i], stacks[i]);
 17a:	8b 84 24 ec 00 00 00 	mov    0xec(%esp),%eax
 181:	8b 54 84 64          	mov    0x64(%esp,%eax,4),%edx
 185:	8b 84 24 ec 00 00 00 	mov    0xec(%esp),%eax
 18c:	8b 44 84 24          	mov    0x24(%esp,%eax,4),%eax
 190:	89 54 24 08          	mov    %edx,0x8(%esp)
 194:	89 44 24 04          	mov    %eax,0x4(%esp)
 198:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 19f:	e8 80 04 00 00       	call   624 <clone>
 1a4:	8b 94 24 ec 00 00 00 	mov    0xec(%esp),%edx
 1ab:	89 84 94 a4 00 00 00 	mov    %eax,0xa4(%esp,%edx,4)
		printf(1, "main: created thread with pid %d\n", pids[i]);
 1b2:	8b 84 24 ec 00 00 00 	mov    0xec(%esp),%eax
 1b9:	8b 84 84 a4 00 00 00 	mov    0xa4(%esp,%eax,4),%eax
 1c0:	89 44 24 08          	mov    %eax,0x8(%esp)
 1c4:	c7 44 24 04 b4 0b 00 	movl   $0xbb4,0x4(%esp)
 1cb:	00 
 1cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1d3:	e8 3b 05 00 00       	call   713 <printf>
	}

	printf(1, "main: running with %d threads...\n", NUM_THREADS);

	// Start all children
	for (i=0; i<NUM_THREADS; i++) {
 1d8:	83 84 24 ec 00 00 00 	addl   $0x1,0xec(%esp)
 1df:	01 
 1e0:	83 bc 24 ec 00 00 00 	cmpl   $0xf,0xec(%esp)
 1e7:	0f 
 1e8:	0f 8e 78 ff ff ff    	jle    166 <main+0xf8>
		pids[i] = clone(thread, args[i], stacks[i]);
		printf(1, "main: created thread with pid %d\n", pids[i]);
	}
	
	// Wait for all children
	for (i=0; i<NUM_THREADS; i++) {
 1ee:	c7 84 24 ec 00 00 00 	movl   $0x0,0xec(%esp)
 1f5:	00 00 00 00 
 1f9:	e9 8d 00 00 00       	jmp    28b <main+0x21d>
		void *joinstack;
		void *retval;
		int r;
		r = join(pids[i], &joinstack, &retval);
 1fe:	8b 84 24 ec 00 00 00 	mov    0xec(%esp),%eax
 205:	8b 84 84 a4 00 00 00 	mov    0xa4(%esp,%eax,4),%eax
 20c:	8d 54 24 1c          	lea    0x1c(%esp),%edx
 210:	89 54 24 08          	mov    %edx,0x8(%esp)
 214:	8d 54 24 20          	lea    0x20(%esp),%edx
 218:	89 54 24 04          	mov    %edx,0x4(%esp)
 21c:	89 04 24             	mov    %eax,(%esp)
 21f:	e8 08 04 00 00       	call   62c <join>
 224:	89 84 24 e4 00 00 00 	mov    %eax,0xe4(%esp)
		if (r < 0) {
 22b:	83 bc 24 e4 00 00 00 	cmpl   $0x0,0xe4(%esp)
 232:	00 
 233:	79 0b                	jns    240 <main+0x1d2>
			passed = 0;
 235:	c7 84 24 e8 00 00 00 	movl   $0x0,0xe8(%esp)
 23c:	00 00 00 00 
		}
		if (*(int*)retval != i) {
 240:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 244:	8b 00                	mov    (%eax),%eax
 246:	3b 84 24 ec 00 00 00 	cmp    0xec(%esp),%eax
 24d:	74 0b                	je     25a <main+0x1ec>
			passed = 0;
 24f:	c7 84 24 e8 00 00 00 	movl   $0x0,0xe8(%esp)
 256:	00 00 00 00 
		}
		printf(1, "main: thread %d joined...retval=%d\n", i, *(int*)retval);
 25a:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 25e:	8b 00                	mov    (%eax),%eax
 260:	89 44 24 0c          	mov    %eax,0xc(%esp)
 264:	8b 84 24 ec 00 00 00 	mov    0xec(%esp),%eax
 26b:	89 44 24 08          	mov    %eax,0x8(%esp)
 26f:	c7 44 24 04 d8 0b 00 	movl   $0xbd8,0x4(%esp)
 276:	00 
 277:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 27e:	e8 90 04 00 00       	call   713 <printf>
		pids[i] = clone(thread, args[i], stacks[i]);
		printf(1, "main: created thread with pid %d\n", pids[i]);
	}
	
	// Wait for all children
	for (i=0; i<NUM_THREADS; i++) {
 283:	83 84 24 ec 00 00 00 	addl   $0x1,0xec(%esp)
 28a:	01 
 28b:	83 bc 24 ec 00 00 00 	cmpl   $0xf,0xec(%esp)
 292:	0f 
 293:	0f 8e 65 ff ff ff    	jle    1fe <main+0x190>
			passed = 0;
		}
		printf(1, "main: thread %d joined...retval=%d\n", i, *(int*)retval);
	}

	if (passed) {
 299:	83 bc 24 e8 00 00 00 	cmpl   $0x0,0xe8(%esp)
 2a0:	00 
 2a1:	74 16                	je     2b9 <main+0x24b>
		printf(1, "TEST PASSED!\n");
 2a3:	c7 44 24 04 fc 0b 00 	movl   $0xbfc,0x4(%esp)
 2aa:	00 
 2ab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2b2:	e8 5c 04 00 00       	call   713 <printf>
 2b7:	eb 14                	jmp    2cd <main+0x25f>
	}
	else {
		printf(1, "TEST FAILED!\n");
 2b9:	c7 44 24 04 0a 0c 00 	movl   $0xc0a,0x4(%esp)
 2c0:	00 
 2c1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2c8:	e8 46 04 00 00       	call   713 <printf>
	}

	// Clean up memory
	for (i=0; i<NUM_THREADS; i++) {
 2cd:	c7 84 24 ec 00 00 00 	movl   $0x0,0xec(%esp)
 2d4:	00 00 00 00 
 2d8:	eb 2e                	jmp    308 <main+0x29a>
		free(stacks[i]);
 2da:	8b 84 24 ec 00 00 00 	mov    0xec(%esp),%eax
 2e1:	8b 44 84 64          	mov    0x64(%esp,%eax,4),%eax
 2e5:	89 04 24             	mov    %eax,(%esp)
 2e8:	e8 db 05 00 00       	call   8c8 <free>
		free(args[i]);
 2ed:	8b 84 24 ec 00 00 00 	mov    0xec(%esp),%eax
 2f4:	8b 44 84 24          	mov    0x24(%esp,%eax,4),%eax
 2f8:	89 04 24             	mov    %eax,(%esp)
 2fb:	e8 c8 05 00 00       	call   8c8 <free>
	else {
		printf(1, "TEST FAILED!\n");
	}

	// Clean up memory
	for (i=0; i<NUM_THREADS; i++) {
 300:	83 84 24 ec 00 00 00 	addl   $0x1,0xec(%esp)
 307:	01 
 308:	83 bc 24 ec 00 00 00 	cmpl   $0xf,0xec(%esp)
 30f:	0f 
 310:	7e c8                	jle    2da <main+0x26c>
		free(stacks[i]);
		free(args[i]);
	}

	// Exit
	exit();
 312:	e8 65 02 00 00       	call   57c <exit>
 317:	90                   	nop

00000318 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 318:	55                   	push   %ebp
 319:	89 e5                	mov    %esp,%ebp
 31b:	57                   	push   %edi
 31c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 31d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 320:	8b 55 10             	mov    0x10(%ebp),%edx
 323:	8b 45 0c             	mov    0xc(%ebp),%eax
 326:	89 cb                	mov    %ecx,%ebx
 328:	89 df                	mov    %ebx,%edi
 32a:	89 d1                	mov    %edx,%ecx
 32c:	fc                   	cld    
 32d:	f3 aa                	rep stos %al,%es:(%edi)
 32f:	89 ca                	mov    %ecx,%edx
 331:	89 fb                	mov    %edi,%ebx
 333:	89 5d 08             	mov    %ebx,0x8(%ebp)
 336:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 339:	5b                   	pop    %ebx
 33a:	5f                   	pop    %edi
 33b:	5d                   	pop    %ebp
 33c:	c3                   	ret    

0000033d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 33d:	55                   	push   %ebp
 33e:	89 e5                	mov    %esp,%ebp
 340:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 343:	8b 45 08             	mov    0x8(%ebp),%eax
 346:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 349:	90                   	nop
 34a:	8b 45 0c             	mov    0xc(%ebp),%eax
 34d:	0f b6 10             	movzbl (%eax),%edx
 350:	8b 45 08             	mov    0x8(%ebp),%eax
 353:	88 10                	mov    %dl,(%eax)
 355:	8b 45 08             	mov    0x8(%ebp),%eax
 358:	0f b6 00             	movzbl (%eax),%eax
 35b:	84 c0                	test   %al,%al
 35d:	0f 95 c0             	setne  %al
 360:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 364:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 368:	84 c0                	test   %al,%al
 36a:	75 de                	jne    34a <strcpy+0xd>
    ;
  return os;
 36c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 36f:	c9                   	leave  
 370:	c3                   	ret    

00000371 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 371:	55                   	push   %ebp
 372:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 374:	eb 08                	jmp    37e <strcmp+0xd>
    p++, q++;
 376:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 37a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 37e:	8b 45 08             	mov    0x8(%ebp),%eax
 381:	0f b6 00             	movzbl (%eax),%eax
 384:	84 c0                	test   %al,%al
 386:	74 10                	je     398 <strcmp+0x27>
 388:	8b 45 08             	mov    0x8(%ebp),%eax
 38b:	0f b6 10             	movzbl (%eax),%edx
 38e:	8b 45 0c             	mov    0xc(%ebp),%eax
 391:	0f b6 00             	movzbl (%eax),%eax
 394:	38 c2                	cmp    %al,%dl
 396:	74 de                	je     376 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 398:	8b 45 08             	mov    0x8(%ebp),%eax
 39b:	0f b6 00             	movzbl (%eax),%eax
 39e:	0f b6 d0             	movzbl %al,%edx
 3a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a4:	0f b6 00             	movzbl (%eax),%eax
 3a7:	0f b6 c0             	movzbl %al,%eax
 3aa:	89 d1                	mov    %edx,%ecx
 3ac:	29 c1                	sub    %eax,%ecx
 3ae:	89 c8                	mov    %ecx,%eax
}
 3b0:	5d                   	pop    %ebp
 3b1:	c3                   	ret    

000003b2 <strlen>:

uint
strlen(char *s)
{
 3b2:	55                   	push   %ebp
 3b3:	89 e5                	mov    %esp,%ebp
 3b5:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3b8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3bf:	eb 04                	jmp    3c5 <strlen+0x13>
 3c1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3c8:	03 45 08             	add    0x8(%ebp),%eax
 3cb:	0f b6 00             	movzbl (%eax),%eax
 3ce:	84 c0                	test   %al,%al
 3d0:	75 ef                	jne    3c1 <strlen+0xf>
    ;
  return n;
 3d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3d5:	c9                   	leave  
 3d6:	c3                   	ret    

000003d7 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3d7:	55                   	push   %ebp
 3d8:	89 e5                	mov    %esp,%ebp
 3da:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 3dd:	8b 45 10             	mov    0x10(%ebp),%eax
 3e0:	89 44 24 08          	mov    %eax,0x8(%esp)
 3e4:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e7:	89 44 24 04          	mov    %eax,0x4(%esp)
 3eb:	8b 45 08             	mov    0x8(%ebp),%eax
 3ee:	89 04 24             	mov    %eax,(%esp)
 3f1:	e8 22 ff ff ff       	call   318 <stosb>
  return dst;
 3f6:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3f9:	c9                   	leave  
 3fa:	c3                   	ret    

000003fb <strchr>:

char*
strchr(const char *s, char c)
{
 3fb:	55                   	push   %ebp
 3fc:	89 e5                	mov    %esp,%ebp
 3fe:	83 ec 04             	sub    $0x4,%esp
 401:	8b 45 0c             	mov    0xc(%ebp),%eax
 404:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 407:	eb 14                	jmp    41d <strchr+0x22>
    if(*s == c)
 409:	8b 45 08             	mov    0x8(%ebp),%eax
 40c:	0f b6 00             	movzbl (%eax),%eax
 40f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 412:	75 05                	jne    419 <strchr+0x1e>
      return (char*)s;
 414:	8b 45 08             	mov    0x8(%ebp),%eax
 417:	eb 13                	jmp    42c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 419:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 41d:	8b 45 08             	mov    0x8(%ebp),%eax
 420:	0f b6 00             	movzbl (%eax),%eax
 423:	84 c0                	test   %al,%al
 425:	75 e2                	jne    409 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 427:	b8 00 00 00 00       	mov    $0x0,%eax
}
 42c:	c9                   	leave  
 42d:	c3                   	ret    

0000042e <gets>:

char*
gets(char *buf, int max)
{
 42e:	55                   	push   %ebp
 42f:	89 e5                	mov    %esp,%ebp
 431:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 434:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 43b:	eb 44                	jmp    481 <gets+0x53>
    cc = read(0, &c, 1);
 43d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 444:	00 
 445:	8d 45 ef             	lea    -0x11(%ebp),%eax
 448:	89 44 24 04          	mov    %eax,0x4(%esp)
 44c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 453:	e8 3c 01 00 00       	call   594 <read>
 458:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 45b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 45f:	7e 2d                	jle    48e <gets+0x60>
      break;
    buf[i++] = c;
 461:	8b 45 f4             	mov    -0xc(%ebp),%eax
 464:	03 45 08             	add    0x8(%ebp),%eax
 467:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 46b:	88 10                	mov    %dl,(%eax)
 46d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 471:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 475:	3c 0a                	cmp    $0xa,%al
 477:	74 16                	je     48f <gets+0x61>
 479:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 47d:	3c 0d                	cmp    $0xd,%al
 47f:	74 0e                	je     48f <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 481:	8b 45 f4             	mov    -0xc(%ebp),%eax
 484:	83 c0 01             	add    $0x1,%eax
 487:	3b 45 0c             	cmp    0xc(%ebp),%eax
 48a:	7c b1                	jl     43d <gets+0xf>
 48c:	eb 01                	jmp    48f <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 48e:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 48f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 492:	03 45 08             	add    0x8(%ebp),%eax
 495:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 498:	8b 45 08             	mov    0x8(%ebp),%eax
}
 49b:	c9                   	leave  
 49c:	c3                   	ret    

0000049d <stat>:

int
stat(char *n, struct stat *st)
{
 49d:	55                   	push   %ebp
 49e:	89 e5                	mov    %esp,%ebp
 4a0:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4a3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 4aa:	00 
 4ab:	8b 45 08             	mov    0x8(%ebp),%eax
 4ae:	89 04 24             	mov    %eax,(%esp)
 4b1:	e8 06 01 00 00       	call   5bc <open>
 4b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4bd:	79 07                	jns    4c6 <stat+0x29>
    return -1;
 4bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4c4:	eb 23                	jmp    4e9 <stat+0x4c>
  r = fstat(fd, st);
 4c6:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c9:	89 44 24 04          	mov    %eax,0x4(%esp)
 4cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4d0:	89 04 24             	mov    %eax,(%esp)
 4d3:	e8 fc 00 00 00       	call   5d4 <fstat>
 4d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4de:	89 04 24             	mov    %eax,(%esp)
 4e1:	e8 be 00 00 00       	call   5a4 <close>
  return r;
 4e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4e9:	c9                   	leave  
 4ea:	c3                   	ret    

000004eb <atoi>:

int
atoi(const char *s)
{
 4eb:	55                   	push   %ebp
 4ec:	89 e5                	mov    %esp,%ebp
 4ee:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4f1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4f8:	eb 23                	jmp    51d <atoi+0x32>
    n = n*10 + *s++ - '0';
 4fa:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4fd:	89 d0                	mov    %edx,%eax
 4ff:	c1 e0 02             	shl    $0x2,%eax
 502:	01 d0                	add    %edx,%eax
 504:	01 c0                	add    %eax,%eax
 506:	89 c2                	mov    %eax,%edx
 508:	8b 45 08             	mov    0x8(%ebp),%eax
 50b:	0f b6 00             	movzbl (%eax),%eax
 50e:	0f be c0             	movsbl %al,%eax
 511:	01 d0                	add    %edx,%eax
 513:	83 e8 30             	sub    $0x30,%eax
 516:	89 45 fc             	mov    %eax,-0x4(%ebp)
 519:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 51d:	8b 45 08             	mov    0x8(%ebp),%eax
 520:	0f b6 00             	movzbl (%eax),%eax
 523:	3c 2f                	cmp    $0x2f,%al
 525:	7e 0a                	jle    531 <atoi+0x46>
 527:	8b 45 08             	mov    0x8(%ebp),%eax
 52a:	0f b6 00             	movzbl (%eax),%eax
 52d:	3c 39                	cmp    $0x39,%al
 52f:	7e c9                	jle    4fa <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 531:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 534:	c9                   	leave  
 535:	c3                   	ret    

00000536 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 536:	55                   	push   %ebp
 537:	89 e5                	mov    %esp,%ebp
 539:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 53c:	8b 45 08             	mov    0x8(%ebp),%eax
 53f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 542:	8b 45 0c             	mov    0xc(%ebp),%eax
 545:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 548:	eb 13                	jmp    55d <memmove+0x27>
    *dst++ = *src++;
 54a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 54d:	0f b6 10             	movzbl (%eax),%edx
 550:	8b 45 fc             	mov    -0x4(%ebp),%eax
 553:	88 10                	mov    %dl,(%eax)
 555:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 559:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 55d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 561:	0f 9f c0             	setg   %al
 564:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 568:	84 c0                	test   %al,%al
 56a:	75 de                	jne    54a <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 56c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 56f:	c9                   	leave  
 570:	c3                   	ret    
 571:	90                   	nop
 572:	90                   	nop
 573:	90                   	nop

00000574 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 574:	b8 01 00 00 00       	mov    $0x1,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret    

0000057c <exit>:
SYSCALL(exit)
 57c:	b8 02 00 00 00       	mov    $0x2,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <wait>:
SYSCALL(wait)
 584:	b8 03 00 00 00       	mov    $0x3,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <pipe>:
SYSCALL(pipe)
 58c:	b8 04 00 00 00       	mov    $0x4,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret    

00000594 <read>:
SYSCALL(read)
 594:	b8 05 00 00 00       	mov    $0x5,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <write>:
SYSCALL(write)
 59c:	b8 10 00 00 00       	mov    $0x10,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <close>:
SYSCALL(close)
 5a4:	b8 15 00 00 00       	mov    $0x15,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <kill>:
SYSCALL(kill)
 5ac:	b8 06 00 00 00       	mov    $0x6,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <exec>:
SYSCALL(exec)
 5b4:	b8 07 00 00 00       	mov    $0x7,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <open>:
SYSCALL(open)
 5bc:	b8 0f 00 00 00       	mov    $0xf,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <mknod>:
SYSCALL(mknod)
 5c4:	b8 11 00 00 00       	mov    $0x11,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    

000005cc <unlink>:
SYSCALL(unlink)
 5cc:	b8 12 00 00 00       	mov    $0x12,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret    

000005d4 <fstat>:
SYSCALL(fstat)
 5d4:	b8 08 00 00 00       	mov    $0x8,%eax
 5d9:	cd 40                	int    $0x40
 5db:	c3                   	ret    

000005dc <link>:
SYSCALL(link)
 5dc:	b8 13 00 00 00       	mov    $0x13,%eax
 5e1:	cd 40                	int    $0x40
 5e3:	c3                   	ret    

000005e4 <mkdir>:
SYSCALL(mkdir)
 5e4:	b8 14 00 00 00       	mov    $0x14,%eax
 5e9:	cd 40                	int    $0x40
 5eb:	c3                   	ret    

000005ec <chdir>:
SYSCALL(chdir)
 5ec:	b8 09 00 00 00       	mov    $0x9,%eax
 5f1:	cd 40                	int    $0x40
 5f3:	c3                   	ret    

000005f4 <dup>:
SYSCALL(dup)
 5f4:	b8 0a 00 00 00       	mov    $0xa,%eax
 5f9:	cd 40                	int    $0x40
 5fb:	c3                   	ret    

000005fc <getpid>:
SYSCALL(getpid)
 5fc:	b8 0b 00 00 00       	mov    $0xb,%eax
 601:	cd 40                	int    $0x40
 603:	c3                   	ret    

00000604 <sbrk>:
SYSCALL(sbrk)
 604:	b8 0c 00 00 00       	mov    $0xc,%eax
 609:	cd 40                	int    $0x40
 60b:	c3                   	ret    

0000060c <sleep>:
SYSCALL(sleep)
 60c:	b8 0d 00 00 00       	mov    $0xd,%eax
 611:	cd 40                	int    $0x40
 613:	c3                   	ret    

00000614 <uptime>:
SYSCALL(uptime)
 614:	b8 0e 00 00 00       	mov    $0xe,%eax
 619:	cd 40                	int    $0x40
 61b:	c3                   	ret    

0000061c <halt>:
SYSCALL(halt)
 61c:	b8 16 00 00 00       	mov    $0x16,%eax
 621:	cd 40                	int    $0x40
 623:	c3                   	ret    

00000624 <clone>:
SYSCALL(clone)
 624:	b8 19 00 00 00       	mov    $0x19,%eax
 629:	cd 40                	int    $0x40
 62b:	c3                   	ret    

0000062c <join>:
SYSCALL(join)
 62c:	b8 1a 00 00 00       	mov    $0x1a,%eax
 631:	cd 40                	int    $0x40
 633:	c3                   	ret    

00000634 <texit>:
SYSCALL(texit)
 634:	b8 1b 00 00 00       	mov    $0x1b,%eax
 639:	cd 40                	int    $0x40
 63b:	c3                   	ret    

0000063c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 63c:	55                   	push   %ebp
 63d:	89 e5                	mov    %esp,%ebp
 63f:	83 ec 28             	sub    $0x28,%esp
 642:	8b 45 0c             	mov    0xc(%ebp),%eax
 645:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 648:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 64f:	00 
 650:	8d 45 f4             	lea    -0xc(%ebp),%eax
 653:	89 44 24 04          	mov    %eax,0x4(%esp)
 657:	8b 45 08             	mov    0x8(%ebp),%eax
 65a:	89 04 24             	mov    %eax,(%esp)
 65d:	e8 3a ff ff ff       	call   59c <write>
}
 662:	c9                   	leave  
 663:	c3                   	ret    

00000664 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 664:	55                   	push   %ebp
 665:	89 e5                	mov    %esp,%ebp
 667:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 66a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 671:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 675:	74 17                	je     68e <printint+0x2a>
 677:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 67b:	79 11                	jns    68e <printint+0x2a>
    neg = 1;
 67d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 684:	8b 45 0c             	mov    0xc(%ebp),%eax
 687:	f7 d8                	neg    %eax
 689:	89 45 ec             	mov    %eax,-0x14(%ebp)
 68c:	eb 06                	jmp    694 <printint+0x30>
  } else {
    x = xx;
 68e:	8b 45 0c             	mov    0xc(%ebp),%eax
 691:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 694:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 69b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 69e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6a1:	ba 00 00 00 00       	mov    $0x0,%edx
 6a6:	f7 f1                	div    %ecx
 6a8:	89 d0                	mov    %edx,%eax
 6aa:	0f b6 90 7c 0e 00 00 	movzbl 0xe7c(%eax),%edx
 6b1:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6b4:	03 45 f4             	add    -0xc(%ebp),%eax
 6b7:	88 10                	mov    %dl,(%eax)
 6b9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 6bd:	8b 55 10             	mov    0x10(%ebp),%edx
 6c0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 6c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6c6:	ba 00 00 00 00       	mov    $0x0,%edx
 6cb:	f7 75 d4             	divl   -0x2c(%ebp)
 6ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6d1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6d5:	75 c4                	jne    69b <printint+0x37>
  if(neg)
 6d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6db:	74 2a                	je     707 <printint+0xa3>
    buf[i++] = '-';
 6dd:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6e0:	03 45 f4             	add    -0xc(%ebp),%eax
 6e3:	c6 00 2d             	movb   $0x2d,(%eax)
 6e6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 6ea:	eb 1b                	jmp    707 <printint+0xa3>
    putc(fd, buf[i]);
 6ec:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6ef:	03 45 f4             	add    -0xc(%ebp),%eax
 6f2:	0f b6 00             	movzbl (%eax),%eax
 6f5:	0f be c0             	movsbl %al,%eax
 6f8:	89 44 24 04          	mov    %eax,0x4(%esp)
 6fc:	8b 45 08             	mov    0x8(%ebp),%eax
 6ff:	89 04 24             	mov    %eax,(%esp)
 702:	e8 35 ff ff ff       	call   63c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 707:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 70b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 70f:	79 db                	jns    6ec <printint+0x88>
    putc(fd, buf[i]);
}
 711:	c9                   	leave  
 712:	c3                   	ret    

00000713 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 713:	55                   	push   %ebp
 714:	89 e5                	mov    %esp,%ebp
 716:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 719:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 720:	8d 45 0c             	lea    0xc(%ebp),%eax
 723:	83 c0 04             	add    $0x4,%eax
 726:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 729:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 730:	e9 7d 01 00 00       	jmp    8b2 <printf+0x19f>
    c = fmt[i] & 0xff;
 735:	8b 55 0c             	mov    0xc(%ebp),%edx
 738:	8b 45 f0             	mov    -0x10(%ebp),%eax
 73b:	01 d0                	add    %edx,%eax
 73d:	0f b6 00             	movzbl (%eax),%eax
 740:	0f be c0             	movsbl %al,%eax
 743:	25 ff 00 00 00       	and    $0xff,%eax
 748:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 74b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 74f:	75 2c                	jne    77d <printf+0x6a>
      if(c == '%'){
 751:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 755:	75 0c                	jne    763 <printf+0x50>
        state = '%';
 757:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 75e:	e9 4b 01 00 00       	jmp    8ae <printf+0x19b>
      } else {
        putc(fd, c);
 763:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 766:	0f be c0             	movsbl %al,%eax
 769:	89 44 24 04          	mov    %eax,0x4(%esp)
 76d:	8b 45 08             	mov    0x8(%ebp),%eax
 770:	89 04 24             	mov    %eax,(%esp)
 773:	e8 c4 fe ff ff       	call   63c <putc>
 778:	e9 31 01 00 00       	jmp    8ae <printf+0x19b>
      }
    } else if(state == '%'){
 77d:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 781:	0f 85 27 01 00 00    	jne    8ae <printf+0x19b>
      if(c == 'd'){
 787:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 78b:	75 2d                	jne    7ba <printf+0xa7>
        printint(fd, *ap, 10, 1);
 78d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 790:	8b 00                	mov    (%eax),%eax
 792:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 799:	00 
 79a:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 7a1:	00 
 7a2:	89 44 24 04          	mov    %eax,0x4(%esp)
 7a6:	8b 45 08             	mov    0x8(%ebp),%eax
 7a9:	89 04 24             	mov    %eax,(%esp)
 7ac:	e8 b3 fe ff ff       	call   664 <printint>
        ap++;
 7b1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7b5:	e9 ed 00 00 00       	jmp    8a7 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 7ba:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7be:	74 06                	je     7c6 <printf+0xb3>
 7c0:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7c4:	75 2d                	jne    7f3 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 7c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7c9:	8b 00                	mov    (%eax),%eax
 7cb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 7d2:	00 
 7d3:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 7da:	00 
 7db:	89 44 24 04          	mov    %eax,0x4(%esp)
 7df:	8b 45 08             	mov    0x8(%ebp),%eax
 7e2:	89 04 24             	mov    %eax,(%esp)
 7e5:	e8 7a fe ff ff       	call   664 <printint>
        ap++;
 7ea:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7ee:	e9 b4 00 00 00       	jmp    8a7 <printf+0x194>
      } else if(c == 's'){
 7f3:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7f7:	75 46                	jne    83f <printf+0x12c>
        s = (char*)*ap;
 7f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7fc:	8b 00                	mov    (%eax),%eax
 7fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 801:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 805:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 809:	75 27                	jne    832 <printf+0x11f>
          s = "(null)";
 80b:	c7 45 f4 18 0c 00 00 	movl   $0xc18,-0xc(%ebp)
        while(*s != 0){
 812:	eb 1e                	jmp    832 <printf+0x11f>
          putc(fd, *s);
 814:	8b 45 f4             	mov    -0xc(%ebp),%eax
 817:	0f b6 00             	movzbl (%eax),%eax
 81a:	0f be c0             	movsbl %al,%eax
 81d:	89 44 24 04          	mov    %eax,0x4(%esp)
 821:	8b 45 08             	mov    0x8(%ebp),%eax
 824:	89 04 24             	mov    %eax,(%esp)
 827:	e8 10 fe ff ff       	call   63c <putc>
          s++;
 82c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 830:	eb 01                	jmp    833 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 832:	90                   	nop
 833:	8b 45 f4             	mov    -0xc(%ebp),%eax
 836:	0f b6 00             	movzbl (%eax),%eax
 839:	84 c0                	test   %al,%al
 83b:	75 d7                	jne    814 <printf+0x101>
 83d:	eb 68                	jmp    8a7 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 83f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 843:	75 1d                	jne    862 <printf+0x14f>
        putc(fd, *ap);
 845:	8b 45 e8             	mov    -0x18(%ebp),%eax
 848:	8b 00                	mov    (%eax),%eax
 84a:	0f be c0             	movsbl %al,%eax
 84d:	89 44 24 04          	mov    %eax,0x4(%esp)
 851:	8b 45 08             	mov    0x8(%ebp),%eax
 854:	89 04 24             	mov    %eax,(%esp)
 857:	e8 e0 fd ff ff       	call   63c <putc>
        ap++;
 85c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 860:	eb 45                	jmp    8a7 <printf+0x194>
      } else if(c == '%'){
 862:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 866:	75 17                	jne    87f <printf+0x16c>
        putc(fd, c);
 868:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 86b:	0f be c0             	movsbl %al,%eax
 86e:	89 44 24 04          	mov    %eax,0x4(%esp)
 872:	8b 45 08             	mov    0x8(%ebp),%eax
 875:	89 04 24             	mov    %eax,(%esp)
 878:	e8 bf fd ff ff       	call   63c <putc>
 87d:	eb 28                	jmp    8a7 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 87f:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 886:	00 
 887:	8b 45 08             	mov    0x8(%ebp),%eax
 88a:	89 04 24             	mov    %eax,(%esp)
 88d:	e8 aa fd ff ff       	call   63c <putc>
        putc(fd, c);
 892:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 895:	0f be c0             	movsbl %al,%eax
 898:	89 44 24 04          	mov    %eax,0x4(%esp)
 89c:	8b 45 08             	mov    0x8(%ebp),%eax
 89f:	89 04 24             	mov    %eax,(%esp)
 8a2:	e8 95 fd ff ff       	call   63c <putc>
      }
      state = 0;
 8a7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 8ae:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8b2:	8b 55 0c             	mov    0xc(%ebp),%edx
 8b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b8:	01 d0                	add    %edx,%eax
 8ba:	0f b6 00             	movzbl (%eax),%eax
 8bd:	84 c0                	test   %al,%al
 8bf:	0f 85 70 fe ff ff    	jne    735 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8c5:	c9                   	leave  
 8c6:	c3                   	ret    
 8c7:	90                   	nop

000008c8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8c8:	55                   	push   %ebp
 8c9:	89 e5                	mov    %esp,%ebp
 8cb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8ce:	8b 45 08             	mov    0x8(%ebp),%eax
 8d1:	83 e8 08             	sub    $0x8,%eax
 8d4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d7:	a1 98 0e 00 00       	mov    0xe98,%eax
 8dc:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8df:	eb 24                	jmp    905 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e4:	8b 00                	mov    (%eax),%eax
 8e6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8e9:	77 12                	ja     8fd <free+0x35>
 8eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ee:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8f1:	77 24                	ja     917 <free+0x4f>
 8f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f6:	8b 00                	mov    (%eax),%eax
 8f8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8fb:	77 1a                	ja     917 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 900:	8b 00                	mov    (%eax),%eax
 902:	89 45 fc             	mov    %eax,-0x4(%ebp)
 905:	8b 45 f8             	mov    -0x8(%ebp),%eax
 908:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 90b:	76 d4                	jbe    8e1 <free+0x19>
 90d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 910:	8b 00                	mov    (%eax),%eax
 912:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 915:	76 ca                	jbe    8e1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 917:	8b 45 f8             	mov    -0x8(%ebp),%eax
 91a:	8b 40 04             	mov    0x4(%eax),%eax
 91d:	c1 e0 03             	shl    $0x3,%eax
 920:	89 c2                	mov    %eax,%edx
 922:	03 55 f8             	add    -0x8(%ebp),%edx
 925:	8b 45 fc             	mov    -0x4(%ebp),%eax
 928:	8b 00                	mov    (%eax),%eax
 92a:	39 c2                	cmp    %eax,%edx
 92c:	75 24                	jne    952 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 92e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 931:	8b 50 04             	mov    0x4(%eax),%edx
 934:	8b 45 fc             	mov    -0x4(%ebp),%eax
 937:	8b 00                	mov    (%eax),%eax
 939:	8b 40 04             	mov    0x4(%eax),%eax
 93c:	01 c2                	add    %eax,%edx
 93e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 941:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 944:	8b 45 fc             	mov    -0x4(%ebp),%eax
 947:	8b 00                	mov    (%eax),%eax
 949:	8b 10                	mov    (%eax),%edx
 94b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94e:	89 10                	mov    %edx,(%eax)
 950:	eb 0a                	jmp    95c <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 952:	8b 45 fc             	mov    -0x4(%ebp),%eax
 955:	8b 10                	mov    (%eax),%edx
 957:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 95c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95f:	8b 40 04             	mov    0x4(%eax),%eax
 962:	c1 e0 03             	shl    $0x3,%eax
 965:	03 45 fc             	add    -0x4(%ebp),%eax
 968:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 96b:	75 20                	jne    98d <free+0xc5>
    p->s.size += bp->s.size;
 96d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 970:	8b 50 04             	mov    0x4(%eax),%edx
 973:	8b 45 f8             	mov    -0x8(%ebp),%eax
 976:	8b 40 04             	mov    0x4(%eax),%eax
 979:	01 c2                	add    %eax,%edx
 97b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 97e:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 981:	8b 45 f8             	mov    -0x8(%ebp),%eax
 984:	8b 10                	mov    (%eax),%edx
 986:	8b 45 fc             	mov    -0x4(%ebp),%eax
 989:	89 10                	mov    %edx,(%eax)
 98b:	eb 08                	jmp    995 <free+0xcd>
  } else
    p->s.ptr = bp;
 98d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 990:	8b 55 f8             	mov    -0x8(%ebp),%edx
 993:	89 10                	mov    %edx,(%eax)
  freep = p;
 995:	8b 45 fc             	mov    -0x4(%ebp),%eax
 998:	a3 98 0e 00 00       	mov    %eax,0xe98
}
 99d:	c9                   	leave  
 99e:	c3                   	ret    

0000099f <morecore>:

static Header*
morecore(uint nu)
{
 99f:	55                   	push   %ebp
 9a0:	89 e5                	mov    %esp,%ebp
 9a2:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9a5:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9ac:	77 07                	ja     9b5 <morecore+0x16>
    nu = 4096;
 9ae:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9b5:	8b 45 08             	mov    0x8(%ebp),%eax
 9b8:	c1 e0 03             	shl    $0x3,%eax
 9bb:	89 04 24             	mov    %eax,(%esp)
 9be:	e8 41 fc ff ff       	call   604 <sbrk>
 9c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9c6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9ca:	75 07                	jne    9d3 <morecore+0x34>
    return 0;
 9cc:	b8 00 00 00 00       	mov    $0x0,%eax
 9d1:	eb 22                	jmp    9f5 <morecore+0x56>
  hp = (Header*)p;
 9d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9dc:	8b 55 08             	mov    0x8(%ebp),%edx
 9df:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e5:	83 c0 08             	add    $0x8,%eax
 9e8:	89 04 24             	mov    %eax,(%esp)
 9eb:	e8 d8 fe ff ff       	call   8c8 <free>
  return freep;
 9f0:	a1 98 0e 00 00       	mov    0xe98,%eax
}
 9f5:	c9                   	leave  
 9f6:	c3                   	ret    

000009f7 <malloc>:

void*
malloc(uint nbytes)
{
 9f7:	55                   	push   %ebp
 9f8:	89 e5                	mov    %esp,%ebp
 9fa:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9fd:	8b 45 08             	mov    0x8(%ebp),%eax
 a00:	83 c0 07             	add    $0x7,%eax
 a03:	c1 e8 03             	shr    $0x3,%eax
 a06:	83 c0 01             	add    $0x1,%eax
 a09:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a0c:	a1 98 0e 00 00       	mov    0xe98,%eax
 a11:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a14:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a18:	75 23                	jne    a3d <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a1a:	c7 45 f0 90 0e 00 00 	movl   $0xe90,-0x10(%ebp)
 a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a24:	a3 98 0e 00 00       	mov    %eax,0xe98
 a29:	a1 98 0e 00 00       	mov    0xe98,%eax
 a2e:	a3 90 0e 00 00       	mov    %eax,0xe90
    base.s.size = 0;
 a33:	c7 05 94 0e 00 00 00 	movl   $0x0,0xe94
 a3a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a40:	8b 00                	mov    (%eax),%eax
 a42:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a48:	8b 40 04             	mov    0x4(%eax),%eax
 a4b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a4e:	72 4d                	jb     a9d <malloc+0xa6>
      if(p->s.size == nunits)
 a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a53:	8b 40 04             	mov    0x4(%eax),%eax
 a56:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a59:	75 0c                	jne    a67 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5e:	8b 10                	mov    (%eax),%edx
 a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a63:	89 10                	mov    %edx,(%eax)
 a65:	eb 26                	jmp    a8d <malloc+0x96>
      else {
        p->s.size -= nunits;
 a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6a:	8b 40 04             	mov    0x4(%eax),%eax
 a6d:	89 c2                	mov    %eax,%edx
 a6f:	2b 55 ec             	sub    -0x14(%ebp),%edx
 a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a75:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7b:	8b 40 04             	mov    0x4(%eax),%eax
 a7e:	c1 e0 03             	shl    $0x3,%eax
 a81:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a87:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a8a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a90:	a3 98 0e 00 00       	mov    %eax,0xe98
      return (void*)(p + 1);
 a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a98:	83 c0 08             	add    $0x8,%eax
 a9b:	eb 38                	jmp    ad5 <malloc+0xde>
    }
    if(p == freep)
 a9d:	a1 98 0e 00 00       	mov    0xe98,%eax
 aa2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 aa5:	75 1b                	jne    ac2 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 aa7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 aaa:	89 04 24             	mov    %eax,(%esp)
 aad:	e8 ed fe ff ff       	call   99f <morecore>
 ab2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ab5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ab9:	75 07                	jne    ac2 <malloc+0xcb>
        return 0;
 abb:	b8 00 00 00 00       	mov    $0x0,%eax
 ac0:	eb 13                	jmp    ad5 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 acb:	8b 00                	mov    (%eax),%eax
 acd:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 ad0:	e9 70 ff ff ff       	jmp    a45 <malloc+0x4e>
}
 ad5:	c9                   	leave  
 ad6:	c3                   	ret    
 ad7:	90                   	nop
