
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
   d:	e8 e2 05 00 00       	call   5f4 <sleep>
	printf(1, "thread %d: started...\n", *(int*)arg);
  12:	8b 45 08             	mov    0x8(%ebp),%eax
  15:	8b 00                	mov    (%eax),%eax
  17:	89 44 24 08          	mov    %eax,0x8(%esp)
  1b:	c7 44 24 04 c0 0a 00 	movl   $0xac0,0x4(%esp)
  22:	00 
  23:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  2a:	e8 cc 06 00 00       	call   6fb <printf>

	for (i=0; i<TARGET_COUNT_PER_THREAD; i++) {
  2f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  36:	eb 20                	jmp    58 <thread+0x58>
		sleep(0);
  38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  3f:	e8 b0 05 00 00       	call   5f4 <sleep>
		counter++;
  44:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
		sleep(0);
  48:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  4f:	e8 a0 05 00 00       	call   5f4 <sleep>
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
  67:	e8 b0 05 00 00       	call   61c <texit>
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
  9c:	e8 3e 09 00 00       	call   9df <malloc>
  a1:	8b 94 24 ec 00 00 00 	mov    0xec(%esp),%edx
  a8:	89 44 94 64          	mov    %eax,0x64(%esp,%edx,4)
		if (!stacks[i]) {
  ac:	8b 84 24 ec 00 00 00 	mov    0xec(%esp),%eax
  b3:	8b 44 84 64          	mov    0x64(%esp,%eax,4),%eax
  b7:	85 c0                	test   %eax,%eax
  b9:	75 19                	jne    d4 <main+0x66>
			printf(1, "main: could not get stack for thread %d, exiting...\n");
  bb:	c7 44 24 04 d8 0a 00 	movl   $0xad8,0x4(%esp)
  c2:	00 
  c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  ca:	e8 2c 06 00 00       	call   6fb <printf>
			exit();
  cf:	e8 90 04 00 00       	call   564 <exit>
		}

		args[i] = (int*) malloc(sizeof(int));
  d4:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  db:	e8 ff 08 00 00       	call   9df <malloc>
  e0:	8b 94 24 ec 00 00 00 	mov    0xec(%esp),%edx
  e7:	89 44 94 24          	mov    %eax,0x24(%esp,%edx,4)
		if (!args[i]) {
  eb:	8b 84 24 ec 00 00 00 	mov    0xec(%esp),%eax
  f2:	8b 44 84 24          	mov    0x24(%esp,%eax,4),%eax
  f6:	85 c0                	test   %eax,%eax
  f8:	75 19                	jne    113 <main+0xa5>
			printf(1, "main: could not get memory (for arg) for thread %d, exiting...\n");
  fa:	c7 44 24 04 10 0b 00 	movl   $0xb10,0x4(%esp)
 101:	00 
 102:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 109:	e8 ed 05 00 00       	call   6fb <printf>
			exit();
 10e:	e8 51 04 00 00       	call   564 <exit>
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
 145:	c7 44 24 04 50 0b 00 	movl   $0xb50,0x4(%esp)
 14c:	00 
 14d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 154:	e8 a2 05 00 00       	call   6fb <printf>

	// Start all children
	for (i=0; i<NUM_THREADS; i++) {
 159:	c7 84 24 ec 00 00 00 	movl   $0x0,0xec(%esp)
 160:	00 00 00 00 
 164:	eb 66                	jmp    1cc <main+0x15e>
		pids[i] = clone(thread, args[i], stacks[i]);
 166:	8b 84 24 ec 00 00 00 	mov    0xec(%esp),%eax
 16d:	8b 54 84 64          	mov    0x64(%esp,%eax,4),%edx
 171:	8b 84 24 ec 00 00 00 	mov    0xec(%esp),%eax
 178:	8b 44 84 24          	mov    0x24(%esp,%eax,4),%eax
 17c:	89 54 24 08          	mov    %edx,0x8(%esp)
 180:	89 44 24 04          	mov    %eax,0x4(%esp)
 184:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 18b:	e8 7c 04 00 00       	call   60c <clone>
 190:	8b 94 24 ec 00 00 00 	mov    0xec(%esp),%edx
 197:	89 84 94 a4 00 00 00 	mov    %eax,0xa4(%esp,%edx,4)
		printf(1, "main: created thread with pid %d\n", pids[i]);
 19e:	8b 84 24 ec 00 00 00 	mov    0xec(%esp),%eax
 1a5:	8b 84 84 a4 00 00 00 	mov    0xa4(%esp,%eax,4),%eax
 1ac:	89 44 24 08          	mov    %eax,0x8(%esp)
 1b0:	c7 44 24 04 74 0b 00 	movl   $0xb74,0x4(%esp)
 1b7:	00 
 1b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1bf:	e8 37 05 00 00       	call   6fb <printf>
	}

	printf(1, "main: running with %d threads...\n", NUM_THREADS);

	// Start all children
	for (i=0; i<NUM_THREADS; i++) {
 1c4:	83 84 24 ec 00 00 00 	addl   $0x1,0xec(%esp)
 1cb:	01 
 1cc:	83 bc 24 ec 00 00 00 	cmpl   $0xf,0xec(%esp)
 1d3:	0f 
 1d4:	7e 90                	jle    166 <main+0xf8>
		pids[i] = clone(thread, args[i], stacks[i]);
		printf(1, "main: created thread with pid %d\n", pids[i]);
	}
	
	// Wait for all children
	for (i=0; i<NUM_THREADS; i++) {
 1d6:	c7 84 24 ec 00 00 00 	movl   $0x0,0xec(%esp)
 1dd:	00 00 00 00 
 1e1:	e9 8d 00 00 00       	jmp    273 <main+0x205>
		void *joinstack;
		void *retval;
		int r;
		r = join(pids[i], &joinstack, &retval);
 1e6:	8b 84 24 ec 00 00 00 	mov    0xec(%esp),%eax
 1ed:	8b 84 84 a4 00 00 00 	mov    0xa4(%esp,%eax,4),%eax
 1f4:	8d 54 24 1c          	lea    0x1c(%esp),%edx
 1f8:	89 54 24 08          	mov    %edx,0x8(%esp)
 1fc:	8d 54 24 20          	lea    0x20(%esp),%edx
 200:	89 54 24 04          	mov    %edx,0x4(%esp)
 204:	89 04 24             	mov    %eax,(%esp)
 207:	e8 08 04 00 00       	call   614 <join>
 20c:	89 84 24 e4 00 00 00 	mov    %eax,0xe4(%esp)
		if (r < 0) {
 213:	83 bc 24 e4 00 00 00 	cmpl   $0x0,0xe4(%esp)
 21a:	00 
 21b:	79 0b                	jns    228 <main+0x1ba>
			passed = 0;
 21d:	c7 84 24 e8 00 00 00 	movl   $0x0,0xe8(%esp)
 224:	00 00 00 00 
		}
		if (*(int*)retval != i) {
 228:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 22c:	8b 00                	mov    (%eax),%eax
 22e:	3b 84 24 ec 00 00 00 	cmp    0xec(%esp),%eax
 235:	74 0b                	je     242 <main+0x1d4>
			passed = 0;
 237:	c7 84 24 e8 00 00 00 	movl   $0x0,0xe8(%esp)
 23e:	00 00 00 00 
		}
		printf(1, "main: thread %d joined...retval=%d\n", i, *(int*)retval);
 242:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 246:	8b 00                	mov    (%eax),%eax
 248:	89 44 24 0c          	mov    %eax,0xc(%esp)
 24c:	8b 84 24 ec 00 00 00 	mov    0xec(%esp),%eax
 253:	89 44 24 08          	mov    %eax,0x8(%esp)
 257:	c7 44 24 04 98 0b 00 	movl   $0xb98,0x4(%esp)
 25e:	00 
 25f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 266:	e8 90 04 00 00       	call   6fb <printf>
		pids[i] = clone(thread, args[i], stacks[i]);
		printf(1, "main: created thread with pid %d\n", pids[i]);
	}
	
	// Wait for all children
	for (i=0; i<NUM_THREADS; i++) {
 26b:	83 84 24 ec 00 00 00 	addl   $0x1,0xec(%esp)
 272:	01 
 273:	83 bc 24 ec 00 00 00 	cmpl   $0xf,0xec(%esp)
 27a:	0f 
 27b:	0f 8e 65 ff ff ff    	jle    1e6 <main+0x178>
			passed = 0;
		}
		printf(1, "main: thread %d joined...retval=%d\n", i, *(int*)retval);
	}

	if (passed) {
 281:	83 bc 24 e8 00 00 00 	cmpl   $0x0,0xe8(%esp)
 288:	00 
 289:	74 16                	je     2a1 <main+0x233>
		printf(1, "TEST PASSED!\n");
 28b:	c7 44 24 04 bc 0b 00 	movl   $0xbbc,0x4(%esp)
 292:	00 
 293:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 29a:	e8 5c 04 00 00       	call   6fb <printf>
 29f:	eb 14                	jmp    2b5 <main+0x247>
	}
	else {
		printf(1, "TEST FAILED!\n");
 2a1:	c7 44 24 04 ca 0b 00 	movl   $0xbca,0x4(%esp)
 2a8:	00 
 2a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2b0:	e8 46 04 00 00       	call   6fb <printf>
	}

	// Clean up memory
	for (i=0; i<NUM_THREADS; i++) {
 2b5:	c7 84 24 ec 00 00 00 	movl   $0x0,0xec(%esp)
 2bc:	00 00 00 00 
 2c0:	eb 2e                	jmp    2f0 <main+0x282>
		free(stacks[i]);
 2c2:	8b 84 24 ec 00 00 00 	mov    0xec(%esp),%eax
 2c9:	8b 44 84 64          	mov    0x64(%esp,%eax,4),%eax
 2cd:	89 04 24             	mov    %eax,(%esp)
 2d0:	e8 db 05 00 00       	call   8b0 <free>
		free(args[i]);
 2d5:	8b 84 24 ec 00 00 00 	mov    0xec(%esp),%eax
 2dc:	8b 44 84 24          	mov    0x24(%esp,%eax,4),%eax
 2e0:	89 04 24             	mov    %eax,(%esp)
 2e3:	e8 c8 05 00 00       	call   8b0 <free>
	else {
		printf(1, "TEST FAILED!\n");
	}

	// Clean up memory
	for (i=0; i<NUM_THREADS; i++) {
 2e8:	83 84 24 ec 00 00 00 	addl   $0x1,0xec(%esp)
 2ef:	01 
 2f0:	83 bc 24 ec 00 00 00 	cmpl   $0xf,0xec(%esp)
 2f7:	0f 
 2f8:	7e c8                	jle    2c2 <main+0x254>
		free(stacks[i]);
		free(args[i]);
	}

	// Exit
	exit();
 2fa:	e8 65 02 00 00       	call   564 <exit>
 2ff:	90                   	nop

00000300 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 300:	55                   	push   %ebp
 301:	89 e5                	mov    %esp,%ebp
 303:	57                   	push   %edi
 304:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 305:	8b 4d 08             	mov    0x8(%ebp),%ecx
 308:	8b 55 10             	mov    0x10(%ebp),%edx
 30b:	8b 45 0c             	mov    0xc(%ebp),%eax
 30e:	89 cb                	mov    %ecx,%ebx
 310:	89 df                	mov    %ebx,%edi
 312:	89 d1                	mov    %edx,%ecx
 314:	fc                   	cld    
 315:	f3 aa                	rep stos %al,%es:(%edi)
 317:	89 ca                	mov    %ecx,%edx
 319:	89 fb                	mov    %edi,%ebx
 31b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 31e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 321:	5b                   	pop    %ebx
 322:	5f                   	pop    %edi
 323:	5d                   	pop    %ebp
 324:	c3                   	ret    

00000325 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 325:	55                   	push   %ebp
 326:	89 e5                	mov    %esp,%ebp
 328:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 32b:	8b 45 08             	mov    0x8(%ebp),%eax
 32e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 331:	90                   	nop
 332:	8b 45 0c             	mov    0xc(%ebp),%eax
 335:	0f b6 10             	movzbl (%eax),%edx
 338:	8b 45 08             	mov    0x8(%ebp),%eax
 33b:	88 10                	mov    %dl,(%eax)
 33d:	8b 45 08             	mov    0x8(%ebp),%eax
 340:	0f b6 00             	movzbl (%eax),%eax
 343:	84 c0                	test   %al,%al
 345:	0f 95 c0             	setne  %al
 348:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 34c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 350:	84 c0                	test   %al,%al
 352:	75 de                	jne    332 <strcpy+0xd>
    ;
  return os;
 354:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 357:	c9                   	leave  
 358:	c3                   	ret    

00000359 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 359:	55                   	push   %ebp
 35a:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 35c:	eb 08                	jmp    366 <strcmp+0xd>
    p++, q++;
 35e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 362:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 366:	8b 45 08             	mov    0x8(%ebp),%eax
 369:	0f b6 00             	movzbl (%eax),%eax
 36c:	84 c0                	test   %al,%al
 36e:	74 10                	je     380 <strcmp+0x27>
 370:	8b 45 08             	mov    0x8(%ebp),%eax
 373:	0f b6 10             	movzbl (%eax),%edx
 376:	8b 45 0c             	mov    0xc(%ebp),%eax
 379:	0f b6 00             	movzbl (%eax),%eax
 37c:	38 c2                	cmp    %al,%dl
 37e:	74 de                	je     35e <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 380:	8b 45 08             	mov    0x8(%ebp),%eax
 383:	0f b6 00             	movzbl (%eax),%eax
 386:	0f b6 d0             	movzbl %al,%edx
 389:	8b 45 0c             	mov    0xc(%ebp),%eax
 38c:	0f b6 00             	movzbl (%eax),%eax
 38f:	0f b6 c0             	movzbl %al,%eax
 392:	89 d1                	mov    %edx,%ecx
 394:	29 c1                	sub    %eax,%ecx
 396:	89 c8                	mov    %ecx,%eax
}
 398:	5d                   	pop    %ebp
 399:	c3                   	ret    

0000039a <strlen>:

uint
strlen(char *s)
{
 39a:	55                   	push   %ebp
 39b:	89 e5                	mov    %esp,%ebp
 39d:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3a0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3a7:	eb 04                	jmp    3ad <strlen+0x13>
 3a9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3b0:	03 45 08             	add    0x8(%ebp),%eax
 3b3:	0f b6 00             	movzbl (%eax),%eax
 3b6:	84 c0                	test   %al,%al
 3b8:	75 ef                	jne    3a9 <strlen+0xf>
    ;
  return n;
 3ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3bd:	c9                   	leave  
 3be:	c3                   	ret    

000003bf <memset>:

void*
memset(void *dst, int c, uint n)
{
 3bf:	55                   	push   %ebp
 3c0:	89 e5                	mov    %esp,%ebp
 3c2:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 3c5:	8b 45 10             	mov    0x10(%ebp),%eax
 3c8:	89 44 24 08          	mov    %eax,0x8(%esp)
 3cc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3cf:	89 44 24 04          	mov    %eax,0x4(%esp)
 3d3:	8b 45 08             	mov    0x8(%ebp),%eax
 3d6:	89 04 24             	mov    %eax,(%esp)
 3d9:	e8 22 ff ff ff       	call   300 <stosb>
  return dst;
 3de:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3e1:	c9                   	leave  
 3e2:	c3                   	ret    

000003e3 <strchr>:

char*
strchr(const char *s, char c)
{
 3e3:	55                   	push   %ebp
 3e4:	89 e5                	mov    %esp,%ebp
 3e6:	83 ec 04             	sub    $0x4,%esp
 3e9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ec:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3ef:	eb 14                	jmp    405 <strchr+0x22>
    if(*s == c)
 3f1:	8b 45 08             	mov    0x8(%ebp),%eax
 3f4:	0f b6 00             	movzbl (%eax),%eax
 3f7:	3a 45 fc             	cmp    -0x4(%ebp),%al
 3fa:	75 05                	jne    401 <strchr+0x1e>
      return (char*)s;
 3fc:	8b 45 08             	mov    0x8(%ebp),%eax
 3ff:	eb 13                	jmp    414 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 401:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 405:	8b 45 08             	mov    0x8(%ebp),%eax
 408:	0f b6 00             	movzbl (%eax),%eax
 40b:	84 c0                	test   %al,%al
 40d:	75 e2                	jne    3f1 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 40f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 414:	c9                   	leave  
 415:	c3                   	ret    

00000416 <gets>:

char*
gets(char *buf, int max)
{
 416:	55                   	push   %ebp
 417:	89 e5                	mov    %esp,%ebp
 419:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 41c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 423:	eb 44                	jmp    469 <gets+0x53>
    cc = read(0, &c, 1);
 425:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 42c:	00 
 42d:	8d 45 ef             	lea    -0x11(%ebp),%eax
 430:	89 44 24 04          	mov    %eax,0x4(%esp)
 434:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 43b:	e8 3c 01 00 00       	call   57c <read>
 440:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 443:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 447:	7e 2d                	jle    476 <gets+0x60>
      break;
    buf[i++] = c;
 449:	8b 45 f4             	mov    -0xc(%ebp),%eax
 44c:	03 45 08             	add    0x8(%ebp),%eax
 44f:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 453:	88 10                	mov    %dl,(%eax)
 455:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 459:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 45d:	3c 0a                	cmp    $0xa,%al
 45f:	74 16                	je     477 <gets+0x61>
 461:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 465:	3c 0d                	cmp    $0xd,%al
 467:	74 0e                	je     477 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 469:	8b 45 f4             	mov    -0xc(%ebp),%eax
 46c:	83 c0 01             	add    $0x1,%eax
 46f:	3b 45 0c             	cmp    0xc(%ebp),%eax
 472:	7c b1                	jl     425 <gets+0xf>
 474:	eb 01                	jmp    477 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 476:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 477:	8b 45 f4             	mov    -0xc(%ebp),%eax
 47a:	03 45 08             	add    0x8(%ebp),%eax
 47d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 480:	8b 45 08             	mov    0x8(%ebp),%eax
}
 483:	c9                   	leave  
 484:	c3                   	ret    

00000485 <stat>:

int
stat(char *n, struct stat *st)
{
 485:	55                   	push   %ebp
 486:	89 e5                	mov    %esp,%ebp
 488:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 48b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 492:	00 
 493:	8b 45 08             	mov    0x8(%ebp),%eax
 496:	89 04 24             	mov    %eax,(%esp)
 499:	e8 06 01 00 00       	call   5a4 <open>
 49e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4a5:	79 07                	jns    4ae <stat+0x29>
    return -1;
 4a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4ac:	eb 23                	jmp    4d1 <stat+0x4c>
  r = fstat(fd, st);
 4ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 4b1:	89 44 24 04          	mov    %eax,0x4(%esp)
 4b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b8:	89 04 24             	mov    %eax,(%esp)
 4bb:	e8 fc 00 00 00       	call   5bc <fstat>
 4c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c6:	89 04 24             	mov    %eax,(%esp)
 4c9:	e8 be 00 00 00       	call   58c <close>
  return r;
 4ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4d1:	c9                   	leave  
 4d2:	c3                   	ret    

000004d3 <atoi>:

int
atoi(const char *s)
{
 4d3:	55                   	push   %ebp
 4d4:	89 e5                	mov    %esp,%ebp
 4d6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4d9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4e0:	eb 23                	jmp    505 <atoi+0x32>
    n = n*10 + *s++ - '0';
 4e2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4e5:	89 d0                	mov    %edx,%eax
 4e7:	c1 e0 02             	shl    $0x2,%eax
 4ea:	01 d0                	add    %edx,%eax
 4ec:	01 c0                	add    %eax,%eax
 4ee:	89 c2                	mov    %eax,%edx
 4f0:	8b 45 08             	mov    0x8(%ebp),%eax
 4f3:	0f b6 00             	movzbl (%eax),%eax
 4f6:	0f be c0             	movsbl %al,%eax
 4f9:	01 d0                	add    %edx,%eax
 4fb:	83 e8 30             	sub    $0x30,%eax
 4fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
 501:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 505:	8b 45 08             	mov    0x8(%ebp),%eax
 508:	0f b6 00             	movzbl (%eax),%eax
 50b:	3c 2f                	cmp    $0x2f,%al
 50d:	7e 0a                	jle    519 <atoi+0x46>
 50f:	8b 45 08             	mov    0x8(%ebp),%eax
 512:	0f b6 00             	movzbl (%eax),%eax
 515:	3c 39                	cmp    $0x39,%al
 517:	7e c9                	jle    4e2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 519:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 51c:	c9                   	leave  
 51d:	c3                   	ret    

0000051e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 51e:	55                   	push   %ebp
 51f:	89 e5                	mov    %esp,%ebp
 521:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 524:	8b 45 08             	mov    0x8(%ebp),%eax
 527:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 52a:	8b 45 0c             	mov    0xc(%ebp),%eax
 52d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 530:	eb 13                	jmp    545 <memmove+0x27>
    *dst++ = *src++;
 532:	8b 45 f8             	mov    -0x8(%ebp),%eax
 535:	0f b6 10             	movzbl (%eax),%edx
 538:	8b 45 fc             	mov    -0x4(%ebp),%eax
 53b:	88 10                	mov    %dl,(%eax)
 53d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 541:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 545:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 549:	0f 9f c0             	setg   %al
 54c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 550:	84 c0                	test   %al,%al
 552:	75 de                	jne    532 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 554:	8b 45 08             	mov    0x8(%ebp),%eax
}
 557:	c9                   	leave  
 558:	c3                   	ret    
 559:	90                   	nop
 55a:	90                   	nop
 55b:	90                   	nop

0000055c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 55c:	b8 01 00 00 00       	mov    $0x1,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret    

00000564 <exit>:
SYSCALL(exit)
 564:	b8 02 00 00 00       	mov    $0x2,%eax
 569:	cd 40                	int    $0x40
 56b:	c3                   	ret    

0000056c <wait>:
SYSCALL(wait)
 56c:	b8 03 00 00 00       	mov    $0x3,%eax
 571:	cd 40                	int    $0x40
 573:	c3                   	ret    

00000574 <pipe>:
SYSCALL(pipe)
 574:	b8 04 00 00 00       	mov    $0x4,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret    

0000057c <read>:
SYSCALL(read)
 57c:	b8 05 00 00 00       	mov    $0x5,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <write>:
SYSCALL(write)
 584:	b8 10 00 00 00       	mov    $0x10,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <close>:
SYSCALL(close)
 58c:	b8 15 00 00 00       	mov    $0x15,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret    

00000594 <kill>:
SYSCALL(kill)
 594:	b8 06 00 00 00       	mov    $0x6,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <exec>:
SYSCALL(exec)
 59c:	b8 07 00 00 00       	mov    $0x7,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <open>:
SYSCALL(open)
 5a4:	b8 0f 00 00 00       	mov    $0xf,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <mknod>:
SYSCALL(mknod)
 5ac:	b8 11 00 00 00       	mov    $0x11,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <unlink>:
SYSCALL(unlink)
 5b4:	b8 12 00 00 00       	mov    $0x12,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <fstat>:
SYSCALL(fstat)
 5bc:	b8 08 00 00 00       	mov    $0x8,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <link>:
SYSCALL(link)
 5c4:	b8 13 00 00 00       	mov    $0x13,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    

000005cc <mkdir>:
SYSCALL(mkdir)
 5cc:	b8 14 00 00 00       	mov    $0x14,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret    

000005d4 <chdir>:
SYSCALL(chdir)
 5d4:	b8 09 00 00 00       	mov    $0x9,%eax
 5d9:	cd 40                	int    $0x40
 5db:	c3                   	ret    

000005dc <dup>:
SYSCALL(dup)
 5dc:	b8 0a 00 00 00       	mov    $0xa,%eax
 5e1:	cd 40                	int    $0x40
 5e3:	c3                   	ret    

000005e4 <getpid>:
SYSCALL(getpid)
 5e4:	b8 0b 00 00 00       	mov    $0xb,%eax
 5e9:	cd 40                	int    $0x40
 5eb:	c3                   	ret    

000005ec <sbrk>:
SYSCALL(sbrk)
 5ec:	b8 0c 00 00 00       	mov    $0xc,%eax
 5f1:	cd 40                	int    $0x40
 5f3:	c3                   	ret    

000005f4 <sleep>:
SYSCALL(sleep)
 5f4:	b8 0d 00 00 00       	mov    $0xd,%eax
 5f9:	cd 40                	int    $0x40
 5fb:	c3                   	ret    

000005fc <uptime>:
SYSCALL(uptime)
 5fc:	b8 0e 00 00 00       	mov    $0xe,%eax
 601:	cd 40                	int    $0x40
 603:	c3                   	ret    

00000604 <halt>:
SYSCALL(halt)
 604:	b8 16 00 00 00       	mov    $0x16,%eax
 609:	cd 40                	int    $0x40
 60b:	c3                   	ret    

0000060c <clone>:
SYSCALL(clone)
 60c:	b8 19 00 00 00       	mov    $0x19,%eax
 611:	cd 40                	int    $0x40
 613:	c3                   	ret    

00000614 <join>:
SYSCALL(join)
 614:	b8 1a 00 00 00       	mov    $0x1a,%eax
 619:	cd 40                	int    $0x40
 61b:	c3                   	ret    

0000061c <texit>:
SYSCALL(texit)
 61c:	b8 1b 00 00 00       	mov    $0x1b,%eax
 621:	cd 40                	int    $0x40
 623:	c3                   	ret    

00000624 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 624:	55                   	push   %ebp
 625:	89 e5                	mov    %esp,%ebp
 627:	83 ec 28             	sub    $0x28,%esp
 62a:	8b 45 0c             	mov    0xc(%ebp),%eax
 62d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 630:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 637:	00 
 638:	8d 45 f4             	lea    -0xc(%ebp),%eax
 63b:	89 44 24 04          	mov    %eax,0x4(%esp)
 63f:	8b 45 08             	mov    0x8(%ebp),%eax
 642:	89 04 24             	mov    %eax,(%esp)
 645:	e8 3a ff ff ff       	call   584 <write>
}
 64a:	c9                   	leave  
 64b:	c3                   	ret    

0000064c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 64c:	55                   	push   %ebp
 64d:	89 e5                	mov    %esp,%ebp
 64f:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 652:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 659:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 65d:	74 17                	je     676 <printint+0x2a>
 65f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 663:	79 11                	jns    676 <printint+0x2a>
    neg = 1;
 665:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 66c:	8b 45 0c             	mov    0xc(%ebp),%eax
 66f:	f7 d8                	neg    %eax
 671:	89 45 ec             	mov    %eax,-0x14(%ebp)
 674:	eb 06                	jmp    67c <printint+0x30>
  } else {
    x = xx;
 676:	8b 45 0c             	mov    0xc(%ebp),%eax
 679:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 67c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 683:	8b 4d 10             	mov    0x10(%ebp),%ecx
 686:	8b 45 ec             	mov    -0x14(%ebp),%eax
 689:	ba 00 00 00 00       	mov    $0x0,%edx
 68e:	f7 f1                	div    %ecx
 690:	89 d0                	mov    %edx,%eax
 692:	0f b6 90 3c 0e 00 00 	movzbl 0xe3c(%eax),%edx
 699:	8d 45 dc             	lea    -0x24(%ebp),%eax
 69c:	03 45 f4             	add    -0xc(%ebp),%eax
 69f:	88 10                	mov    %dl,(%eax)
 6a1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 6a5:	8b 55 10             	mov    0x10(%ebp),%edx
 6a8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 6ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6ae:	ba 00 00 00 00       	mov    $0x0,%edx
 6b3:	f7 75 d4             	divl   -0x2c(%ebp)
 6b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6b9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6bd:	75 c4                	jne    683 <printint+0x37>
  if(neg)
 6bf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6c3:	74 2a                	je     6ef <printint+0xa3>
    buf[i++] = '-';
 6c5:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6c8:	03 45 f4             	add    -0xc(%ebp),%eax
 6cb:	c6 00 2d             	movb   $0x2d,(%eax)
 6ce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 6d2:	eb 1b                	jmp    6ef <printint+0xa3>
    putc(fd, buf[i]);
 6d4:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6d7:	03 45 f4             	add    -0xc(%ebp),%eax
 6da:	0f b6 00             	movzbl (%eax),%eax
 6dd:	0f be c0             	movsbl %al,%eax
 6e0:	89 44 24 04          	mov    %eax,0x4(%esp)
 6e4:	8b 45 08             	mov    0x8(%ebp),%eax
 6e7:	89 04 24             	mov    %eax,(%esp)
 6ea:	e8 35 ff ff ff       	call   624 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6ef:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6f7:	79 db                	jns    6d4 <printint+0x88>
    putc(fd, buf[i]);
}
 6f9:	c9                   	leave  
 6fa:	c3                   	ret    

000006fb <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6fb:	55                   	push   %ebp
 6fc:	89 e5                	mov    %esp,%ebp
 6fe:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 701:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 708:	8d 45 0c             	lea    0xc(%ebp),%eax
 70b:	83 c0 04             	add    $0x4,%eax
 70e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 711:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 718:	e9 7d 01 00 00       	jmp    89a <printf+0x19f>
    c = fmt[i] & 0xff;
 71d:	8b 55 0c             	mov    0xc(%ebp),%edx
 720:	8b 45 f0             	mov    -0x10(%ebp),%eax
 723:	01 d0                	add    %edx,%eax
 725:	0f b6 00             	movzbl (%eax),%eax
 728:	0f be c0             	movsbl %al,%eax
 72b:	25 ff 00 00 00       	and    $0xff,%eax
 730:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 733:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 737:	75 2c                	jne    765 <printf+0x6a>
      if(c == '%'){
 739:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 73d:	75 0c                	jne    74b <printf+0x50>
        state = '%';
 73f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 746:	e9 4b 01 00 00       	jmp    896 <printf+0x19b>
      } else {
        putc(fd, c);
 74b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 74e:	0f be c0             	movsbl %al,%eax
 751:	89 44 24 04          	mov    %eax,0x4(%esp)
 755:	8b 45 08             	mov    0x8(%ebp),%eax
 758:	89 04 24             	mov    %eax,(%esp)
 75b:	e8 c4 fe ff ff       	call   624 <putc>
 760:	e9 31 01 00 00       	jmp    896 <printf+0x19b>
      }
    } else if(state == '%'){
 765:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 769:	0f 85 27 01 00 00    	jne    896 <printf+0x19b>
      if(c == 'd'){
 76f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 773:	75 2d                	jne    7a2 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 775:	8b 45 e8             	mov    -0x18(%ebp),%eax
 778:	8b 00                	mov    (%eax),%eax
 77a:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 781:	00 
 782:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 789:	00 
 78a:	89 44 24 04          	mov    %eax,0x4(%esp)
 78e:	8b 45 08             	mov    0x8(%ebp),%eax
 791:	89 04 24             	mov    %eax,(%esp)
 794:	e8 b3 fe ff ff       	call   64c <printint>
        ap++;
 799:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 79d:	e9 ed 00 00 00       	jmp    88f <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 7a2:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7a6:	74 06                	je     7ae <printf+0xb3>
 7a8:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7ac:	75 2d                	jne    7db <printf+0xe0>
        printint(fd, *ap, 16, 0);
 7ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7b1:	8b 00                	mov    (%eax),%eax
 7b3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 7ba:	00 
 7bb:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 7c2:	00 
 7c3:	89 44 24 04          	mov    %eax,0x4(%esp)
 7c7:	8b 45 08             	mov    0x8(%ebp),%eax
 7ca:	89 04 24             	mov    %eax,(%esp)
 7cd:	e8 7a fe ff ff       	call   64c <printint>
        ap++;
 7d2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7d6:	e9 b4 00 00 00       	jmp    88f <printf+0x194>
      } else if(c == 's'){
 7db:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7df:	75 46                	jne    827 <printf+0x12c>
        s = (char*)*ap;
 7e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7e4:	8b 00                	mov    (%eax),%eax
 7e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7e9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7f1:	75 27                	jne    81a <printf+0x11f>
          s = "(null)";
 7f3:	c7 45 f4 d8 0b 00 00 	movl   $0xbd8,-0xc(%ebp)
        while(*s != 0){
 7fa:	eb 1e                	jmp    81a <printf+0x11f>
          putc(fd, *s);
 7fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ff:	0f b6 00             	movzbl (%eax),%eax
 802:	0f be c0             	movsbl %al,%eax
 805:	89 44 24 04          	mov    %eax,0x4(%esp)
 809:	8b 45 08             	mov    0x8(%ebp),%eax
 80c:	89 04 24             	mov    %eax,(%esp)
 80f:	e8 10 fe ff ff       	call   624 <putc>
          s++;
 814:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 818:	eb 01                	jmp    81b <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 81a:	90                   	nop
 81b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81e:	0f b6 00             	movzbl (%eax),%eax
 821:	84 c0                	test   %al,%al
 823:	75 d7                	jne    7fc <printf+0x101>
 825:	eb 68                	jmp    88f <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 827:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 82b:	75 1d                	jne    84a <printf+0x14f>
        putc(fd, *ap);
 82d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 830:	8b 00                	mov    (%eax),%eax
 832:	0f be c0             	movsbl %al,%eax
 835:	89 44 24 04          	mov    %eax,0x4(%esp)
 839:	8b 45 08             	mov    0x8(%ebp),%eax
 83c:	89 04 24             	mov    %eax,(%esp)
 83f:	e8 e0 fd ff ff       	call   624 <putc>
        ap++;
 844:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 848:	eb 45                	jmp    88f <printf+0x194>
      } else if(c == '%'){
 84a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 84e:	75 17                	jne    867 <printf+0x16c>
        putc(fd, c);
 850:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 853:	0f be c0             	movsbl %al,%eax
 856:	89 44 24 04          	mov    %eax,0x4(%esp)
 85a:	8b 45 08             	mov    0x8(%ebp),%eax
 85d:	89 04 24             	mov    %eax,(%esp)
 860:	e8 bf fd ff ff       	call   624 <putc>
 865:	eb 28                	jmp    88f <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 867:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 86e:	00 
 86f:	8b 45 08             	mov    0x8(%ebp),%eax
 872:	89 04 24             	mov    %eax,(%esp)
 875:	e8 aa fd ff ff       	call   624 <putc>
        putc(fd, c);
 87a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 87d:	0f be c0             	movsbl %al,%eax
 880:	89 44 24 04          	mov    %eax,0x4(%esp)
 884:	8b 45 08             	mov    0x8(%ebp),%eax
 887:	89 04 24             	mov    %eax,(%esp)
 88a:	e8 95 fd ff ff       	call   624 <putc>
      }
      state = 0;
 88f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 896:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 89a:	8b 55 0c             	mov    0xc(%ebp),%edx
 89d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a0:	01 d0                	add    %edx,%eax
 8a2:	0f b6 00             	movzbl (%eax),%eax
 8a5:	84 c0                	test   %al,%al
 8a7:	0f 85 70 fe ff ff    	jne    71d <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8ad:	c9                   	leave  
 8ae:	c3                   	ret    
 8af:	90                   	nop

000008b0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8b0:	55                   	push   %ebp
 8b1:	89 e5                	mov    %esp,%ebp
 8b3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8b6:	8b 45 08             	mov    0x8(%ebp),%eax
 8b9:	83 e8 08             	sub    $0x8,%eax
 8bc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8bf:	a1 58 0e 00 00       	mov    0xe58,%eax
 8c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8c7:	eb 24                	jmp    8ed <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cc:	8b 00                	mov    (%eax),%eax
 8ce:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8d1:	77 12                	ja     8e5 <free+0x35>
 8d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8d9:	77 24                	ja     8ff <free+0x4f>
 8db:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8de:	8b 00                	mov    (%eax),%eax
 8e0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8e3:	77 1a                	ja     8ff <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e8:	8b 00                	mov    (%eax),%eax
 8ea:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8f3:	76 d4                	jbe    8c9 <free+0x19>
 8f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f8:	8b 00                	mov    (%eax),%eax
 8fa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8fd:	76 ca                	jbe    8c9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 8ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 902:	8b 40 04             	mov    0x4(%eax),%eax
 905:	c1 e0 03             	shl    $0x3,%eax
 908:	89 c2                	mov    %eax,%edx
 90a:	03 55 f8             	add    -0x8(%ebp),%edx
 90d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 910:	8b 00                	mov    (%eax),%eax
 912:	39 c2                	cmp    %eax,%edx
 914:	75 24                	jne    93a <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 916:	8b 45 f8             	mov    -0x8(%ebp),%eax
 919:	8b 50 04             	mov    0x4(%eax),%edx
 91c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91f:	8b 00                	mov    (%eax),%eax
 921:	8b 40 04             	mov    0x4(%eax),%eax
 924:	01 c2                	add    %eax,%edx
 926:	8b 45 f8             	mov    -0x8(%ebp),%eax
 929:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 92c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92f:	8b 00                	mov    (%eax),%eax
 931:	8b 10                	mov    (%eax),%edx
 933:	8b 45 f8             	mov    -0x8(%ebp),%eax
 936:	89 10                	mov    %edx,(%eax)
 938:	eb 0a                	jmp    944 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 93a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93d:	8b 10                	mov    (%eax),%edx
 93f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 942:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 944:	8b 45 fc             	mov    -0x4(%ebp),%eax
 947:	8b 40 04             	mov    0x4(%eax),%eax
 94a:	c1 e0 03             	shl    $0x3,%eax
 94d:	03 45 fc             	add    -0x4(%ebp),%eax
 950:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 953:	75 20                	jne    975 <free+0xc5>
    p->s.size += bp->s.size;
 955:	8b 45 fc             	mov    -0x4(%ebp),%eax
 958:	8b 50 04             	mov    0x4(%eax),%edx
 95b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95e:	8b 40 04             	mov    0x4(%eax),%eax
 961:	01 c2                	add    %eax,%edx
 963:	8b 45 fc             	mov    -0x4(%ebp),%eax
 966:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 969:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96c:	8b 10                	mov    (%eax),%edx
 96e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 971:	89 10                	mov    %edx,(%eax)
 973:	eb 08                	jmp    97d <free+0xcd>
  } else
    p->s.ptr = bp;
 975:	8b 45 fc             	mov    -0x4(%ebp),%eax
 978:	8b 55 f8             	mov    -0x8(%ebp),%edx
 97b:	89 10                	mov    %edx,(%eax)
  freep = p;
 97d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 980:	a3 58 0e 00 00       	mov    %eax,0xe58
}
 985:	c9                   	leave  
 986:	c3                   	ret    

00000987 <morecore>:

static Header*
morecore(uint nu)
{
 987:	55                   	push   %ebp
 988:	89 e5                	mov    %esp,%ebp
 98a:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 98d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 994:	77 07                	ja     99d <morecore+0x16>
    nu = 4096;
 996:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 99d:	8b 45 08             	mov    0x8(%ebp),%eax
 9a0:	c1 e0 03             	shl    $0x3,%eax
 9a3:	89 04 24             	mov    %eax,(%esp)
 9a6:	e8 41 fc ff ff       	call   5ec <sbrk>
 9ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9ae:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9b2:	75 07                	jne    9bb <morecore+0x34>
    return 0;
 9b4:	b8 00 00 00 00       	mov    $0x0,%eax
 9b9:	eb 22                	jmp    9dd <morecore+0x56>
  hp = (Header*)p;
 9bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9be:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c4:	8b 55 08             	mov    0x8(%ebp),%edx
 9c7:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9cd:	83 c0 08             	add    $0x8,%eax
 9d0:	89 04 24             	mov    %eax,(%esp)
 9d3:	e8 d8 fe ff ff       	call   8b0 <free>
  return freep;
 9d8:	a1 58 0e 00 00       	mov    0xe58,%eax
}
 9dd:	c9                   	leave  
 9de:	c3                   	ret    

000009df <malloc>:

void*
malloc(uint nbytes)
{
 9df:	55                   	push   %ebp
 9e0:	89 e5                	mov    %esp,%ebp
 9e2:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9e5:	8b 45 08             	mov    0x8(%ebp),%eax
 9e8:	83 c0 07             	add    $0x7,%eax
 9eb:	c1 e8 03             	shr    $0x3,%eax
 9ee:	83 c0 01             	add    $0x1,%eax
 9f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9f4:	a1 58 0e 00 00       	mov    0xe58,%eax
 9f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a00:	75 23                	jne    a25 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a02:	c7 45 f0 50 0e 00 00 	movl   $0xe50,-0x10(%ebp)
 a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a0c:	a3 58 0e 00 00       	mov    %eax,0xe58
 a11:	a1 58 0e 00 00       	mov    0xe58,%eax
 a16:	a3 50 0e 00 00       	mov    %eax,0xe50
    base.s.size = 0;
 a1b:	c7 05 54 0e 00 00 00 	movl   $0x0,0xe54
 a22:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a25:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a28:	8b 00                	mov    (%eax),%eax
 a2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a30:	8b 40 04             	mov    0x4(%eax),%eax
 a33:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a36:	72 4d                	jb     a85 <malloc+0xa6>
      if(p->s.size == nunits)
 a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a3b:	8b 40 04             	mov    0x4(%eax),%eax
 a3e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a41:	75 0c                	jne    a4f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a46:	8b 10                	mov    (%eax),%edx
 a48:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a4b:	89 10                	mov    %edx,(%eax)
 a4d:	eb 26                	jmp    a75 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a52:	8b 40 04             	mov    0x4(%eax),%eax
 a55:	89 c2                	mov    %eax,%edx
 a57:	2b 55 ec             	sub    -0x14(%ebp),%edx
 a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a63:	8b 40 04             	mov    0x4(%eax),%eax
 a66:	c1 e0 03             	shl    $0x3,%eax
 a69:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a72:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a75:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a78:	a3 58 0e 00 00       	mov    %eax,0xe58
      return (void*)(p + 1);
 a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a80:	83 c0 08             	add    $0x8,%eax
 a83:	eb 38                	jmp    abd <malloc+0xde>
    }
    if(p == freep)
 a85:	a1 58 0e 00 00       	mov    0xe58,%eax
 a8a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a8d:	75 1b                	jne    aaa <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a92:	89 04 24             	mov    %eax,(%esp)
 a95:	e8 ed fe ff ff       	call   987 <morecore>
 a9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a9d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 aa1:	75 07                	jne    aaa <malloc+0xcb>
        return 0;
 aa3:	b8 00 00 00 00       	mov    $0x0,%eax
 aa8:	eb 13                	jmp    abd <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aad:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab3:	8b 00                	mov    (%eax),%eax
 ab5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 ab8:	e9 70 ff ff ff       	jmp    a2d <malloc+0x4e>
}
 abd:	c9                   	leave  
 abe:	c3                   	ret    
 abf:	90                   	nop
