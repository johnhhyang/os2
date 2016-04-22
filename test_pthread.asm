
_test_pthread:     file format elf32-i386


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
   d:	e8 a6 05 00 00       	call   5b8 <sleep>
	printf(1, "thread %d: started...\n", *(int*)arg);
  12:	8b 45 08             	mov    0x8(%ebp),%eax
  15:	8b 00                	mov    (%eax),%eax
  17:	89 44 24 08          	mov    %eax,0x8(%esp)
  1b:	c7 44 24 04 ac 0b 00 	movl   $0xbac,0x4(%esp)
  22:	00 
  23:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  2a:	e8 b0 06 00 00       	call   6df <printf>

	for (i=0; i<TARGET_COUNT_PER_THREAD; i++) {
  2f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  36:	eb 20                	jmp    58 <thread+0x58>
		sleep(0);
  38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  3f:	e8 74 05 00 00       	call   5b8 <sleep>
		counter++;
  44:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
		sleep(0);
  48:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  4f:	e8 64 05 00 00       	call   5b8 <sleep>
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

	pthread_exit(arg);
  61:	8b 45 08             	mov    0x8(%ebp),%eax
  64:	89 04 24             	mov    %eax,(%esp)
  67:	e8 c4 0a 00 00       	call   b30 <pthread_exit>
}
  6c:	c9                   	leave  
  6d:	c3                   	ret    

0000006e <main>:

int main(int argc, char **argv)
{
  6e:	55                   	push   %ebp
  6f:	89 e5                	mov    %esp,%ebp
  71:	83 e4 f0             	and    $0xfffffff0,%esp
  74:	81 ec a0 00 00 00    	sub    $0xa0,%esp
	int i;
	int passed = 1;
  7a:	c7 84 24 98 00 00 00 	movl   $0x1,0x98(%esp)
  81:	01 00 00 00 
	int *args[NUM_THREADS];

	//printf(1, "Meep\n");
	// Allocate stacks and args and make sure we have them all
	// Bail if something fails
	for (i=0; i<NUM_THREADS; i++) {
  85:	c7 84 24 9c 00 00 00 	movl   $0x0,0x9c(%esp)
  8c:	00 00 00 00 
  90:	eb 5b                	jmp    ed <main+0x7f>
		args[i] = (int*) malloc(sizeof(int));
  92:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  99:	e8 25 09 00 00       	call   9c3 <malloc>
  9e:	8b 94 24 9c 00 00 00 	mov    0x9c(%esp),%edx
  a5:	89 44 94 14          	mov    %eax,0x14(%esp,%edx,4)
		if (!args[i]) {
  a9:	8b 84 24 9c 00 00 00 	mov    0x9c(%esp),%eax
  b0:	8b 44 84 14          	mov    0x14(%esp,%eax,4),%eax
  b4:	85 c0                	test   %eax,%eax
  b6:	75 19                	jne    d1 <main+0x63>
			printf(1, "main: could not get memory (for arg) for thread %d, exiting...\n");
  b8:	c7 44 24 04 c4 0b 00 	movl   $0xbc4,0x4(%esp)
  bf:	00 
  c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c7:	e8 13 06 00 00       	call   6df <printf>
			exit();
  cc:	e8 57 04 00 00       	call   528 <exit>
		}

		*args[i] = i;
  d1:	8b 84 24 9c 00 00 00 	mov    0x9c(%esp),%eax
  d8:	8b 44 84 14          	mov    0x14(%esp,%eax,4),%eax
  dc:	8b 94 24 9c 00 00 00 	mov    0x9c(%esp),%edx
  e3:	89 10                	mov    %edx,(%eax)
	int *args[NUM_THREADS];

	//printf(1, "Meep\n");
	// Allocate stacks and args and make sure we have them all
	// Bail if something fails
	for (i=0; i<NUM_THREADS; i++) {
  e5:	83 84 24 9c 00 00 00 	addl   $0x1,0x9c(%esp)
  ec:	01 
  ed:	83 bc 24 9c 00 00 00 	cmpl   $0xf,0x9c(%esp)
  f4:	0f 
  f5:	7e 9b                	jle    92 <main+0x24>

		*args[i] = i;
	}

	//printf(1, "Meep2\n");
	printf(1, "main: running with %d threads...\n", NUM_THREADS);
  f7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  fe:	00 
  ff:	c7 44 24 04 04 0c 00 	movl   $0xc04,0x4(%esp)
 106:	00 
 107:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 10e:	e8 cc 05 00 00       	call   6df <printf>

	// Start all children
	for (i=0; i<NUM_THREADS; i++) {
 113:	c7 84 24 9c 00 00 00 	movl   $0x0,0x9c(%esp)
 11a:	00 00 00 00 
 11e:	eb 66                	jmp    186 <main+0x118>
		pthread_create(&threads[i], 0, thread, args[i]);
 120:	8b 84 24 9c 00 00 00 	mov    0x9c(%esp),%eax
 127:	8b 44 84 14          	mov    0x14(%esp,%eax,4),%eax
 12b:	8b 94 24 9c 00 00 00 	mov    0x9c(%esp),%edx
 132:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
 139:	8d 54 24 54          	lea    0x54(%esp),%edx
 13d:	01 ca                	add    %ecx,%edx
 13f:	89 44 24 0c          	mov    %eax,0xc(%esp)
 143:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
 14a:	00 
 14b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 152:	00 
 153:	89 14 24             	mov    %edx,(%esp)
 156:	e8 49 09 00 00       	call   aa4 <pthread_create>
		printf(1, "main: created thread with pid %d\n", threads[i].pid);
 15b:	8b 84 24 9c 00 00 00 	mov    0x9c(%esp),%eax
 162:	8b 44 84 54          	mov    0x54(%esp,%eax,4),%eax
 166:	89 44 24 08          	mov    %eax,0x8(%esp)
 16a:	c7 44 24 04 28 0c 00 	movl   $0xc28,0x4(%esp)
 171:	00 
 172:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 179:	e8 61 05 00 00       	call   6df <printf>

	//printf(1, "Meep2\n");
	printf(1, "main: running with %d threads...\n", NUM_THREADS);

	// Start all children
	for (i=0; i<NUM_THREADS; i++) {
 17e:	83 84 24 9c 00 00 00 	addl   $0x1,0x9c(%esp)
 185:	01 
 186:	83 bc 24 9c 00 00 00 	cmpl   $0xf,0x9c(%esp)
 18d:	0f 
 18e:	7e 90                	jle    120 <main+0xb2>
		printf(1, "main: created thread with pid %d\n", threads[i].pid);
	}
	
	//printf(1, "Meep3\n");
	// Wait for all children
	for (i=0; i<NUM_THREADS; i++) {
 190:	c7 84 24 9c 00 00 00 	movl   $0x0,0x9c(%esp)
 197:	00 00 00 00 
 19b:	e9 aa 00 00 00       	jmp    24a <main+0x1dc>
		void *retval;
		int r;
		r = pthread_join(threads[i], &retval);
 1a0:	8d 44 24 10          	lea    0x10(%esp),%eax
 1a4:	89 44 24 04          	mov    %eax,0x4(%esp)
 1a8:	8b 84 24 9c 00 00 00 	mov    0x9c(%esp),%eax
 1af:	8b 44 84 54          	mov    0x54(%esp,%eax,4),%eax
 1b3:	89 04 24             	mov    %eax,(%esp)
 1b6:	e8 44 09 00 00       	call   aff <pthread_join>
 1bb:	89 84 24 94 00 00 00 	mov    %eax,0x94(%esp)
		if (r < 0) {
 1c2:	83 bc 24 94 00 00 00 	cmpl   $0x0,0x94(%esp)
 1c9:	00 
 1ca:	79 1f                	jns    1eb <main+0x17d>
			printf(1, "your return value for pthread_join is shit\n");
 1cc:	c7 44 24 04 4c 0c 00 	movl   $0xc4c,0x4(%esp)
 1d3:	00 
 1d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1db:	e8 ff 04 00 00       	call   6df <printf>
			passed = 0;
 1e0:	c7 84 24 98 00 00 00 	movl   $0x0,0x98(%esp)
 1e7:	00 00 00 00 
		}
		if (*(int*)retval != i) {
 1eb:	8b 44 24 10          	mov    0x10(%esp),%eax
 1ef:	8b 00                	mov    (%eax),%eax
 1f1:	3b 84 24 9c 00 00 00 	cmp    0x9c(%esp),%eax
 1f8:	74 1f                	je     219 <main+0x1ab>
			printf(1, "your retval is shit\n");
 1fa:	c7 44 24 04 78 0c 00 	movl   $0xc78,0x4(%esp)
 201:	00 
 202:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 209:	e8 d1 04 00 00       	call   6df <printf>
			passed = 0;
 20e:	c7 84 24 98 00 00 00 	movl   $0x0,0x98(%esp)
 215:	00 00 00 00 
		}
		printf(1, "main: thread %d joined...retval=%d\n", i, *(int*)retval);
 219:	8b 44 24 10          	mov    0x10(%esp),%eax
 21d:	8b 00                	mov    (%eax),%eax
 21f:	89 44 24 0c          	mov    %eax,0xc(%esp)
 223:	8b 84 24 9c 00 00 00 	mov    0x9c(%esp),%eax
 22a:	89 44 24 08          	mov    %eax,0x8(%esp)
 22e:	c7 44 24 04 90 0c 00 	movl   $0xc90,0x4(%esp)
 235:	00 
 236:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 23d:	e8 9d 04 00 00       	call   6df <printf>
		printf(1, "main: created thread with pid %d\n", threads[i].pid);
	}
	
	//printf(1, "Meep3\n");
	// Wait for all children
	for (i=0; i<NUM_THREADS; i++) {
 242:	83 84 24 9c 00 00 00 	addl   $0x1,0x9c(%esp)
 249:	01 
 24a:	83 bc 24 9c 00 00 00 	cmpl   $0xf,0x9c(%esp)
 251:	0f 
 252:	0f 8e 48 ff ff ff    	jle    1a0 <main+0x132>
			passed = 0;
		}
		printf(1, "main: thread %d joined...retval=%d\n", i, *(int*)retval);
	}

	if (passed) {
 258:	83 bc 24 98 00 00 00 	cmpl   $0x0,0x98(%esp)
 25f:	00 
 260:	74 16                	je     278 <main+0x20a>
		printf(1, "TEST PASSED!\n");
 262:	c7 44 24 04 b4 0c 00 	movl   $0xcb4,0x4(%esp)
 269:	00 
 26a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 271:	e8 69 04 00 00       	call   6df <printf>
 276:	eb 14                	jmp    28c <main+0x21e>
	}
	else {
		printf(1, "TEST FAILED!\n");
 278:	c7 44 24 04 c2 0c 00 	movl   $0xcc2,0x4(%esp)
 27f:	00 
 280:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 287:	e8 53 04 00 00       	call   6df <printf>
	}

	// Clean up memory
	for (i=0; i<NUM_THREADS; i++) {
 28c:	c7 84 24 9c 00 00 00 	movl   $0x0,0x9c(%esp)
 293:	00 00 00 00 
 297:	eb 1b                	jmp    2b4 <main+0x246>
		free(args[i]);
 299:	8b 84 24 9c 00 00 00 	mov    0x9c(%esp),%eax
 2a0:	8b 44 84 14          	mov    0x14(%esp,%eax,4),%eax
 2a4:	89 04 24             	mov    %eax,(%esp)
 2a7:	e8 e8 05 00 00       	call   894 <free>
	else {
		printf(1, "TEST FAILED!\n");
	}

	// Clean up memory
	for (i=0; i<NUM_THREADS; i++) {
 2ac:	83 84 24 9c 00 00 00 	addl   $0x1,0x9c(%esp)
 2b3:	01 
 2b4:	83 bc 24 9c 00 00 00 	cmpl   $0xf,0x9c(%esp)
 2bb:	0f 
 2bc:	7e db                	jle    299 <main+0x22b>
		free(args[i]);
	}

	// Exit
	exit();
 2be:	e8 65 02 00 00       	call   528 <exit>
 2c3:	90                   	nop

000002c4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2c4:	55                   	push   %ebp
 2c5:	89 e5                	mov    %esp,%ebp
 2c7:	57                   	push   %edi
 2c8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2cc:	8b 55 10             	mov    0x10(%ebp),%edx
 2cf:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d2:	89 cb                	mov    %ecx,%ebx
 2d4:	89 df                	mov    %ebx,%edi
 2d6:	89 d1                	mov    %edx,%ecx
 2d8:	fc                   	cld    
 2d9:	f3 aa                	rep stos %al,%es:(%edi)
 2db:	89 ca                	mov    %ecx,%edx
 2dd:	89 fb                	mov    %edi,%ebx
 2df:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2e2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2e5:	5b                   	pop    %ebx
 2e6:	5f                   	pop    %edi
 2e7:	5d                   	pop    %ebp
 2e8:	c3                   	ret    

000002e9 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2e9:	55                   	push   %ebp
 2ea:	89 e5                	mov    %esp,%ebp
 2ec:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2ef:	8b 45 08             	mov    0x8(%ebp),%eax
 2f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2f5:	90                   	nop
 2f6:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f9:	0f b6 10             	movzbl (%eax),%edx
 2fc:	8b 45 08             	mov    0x8(%ebp),%eax
 2ff:	88 10                	mov    %dl,(%eax)
 301:	8b 45 08             	mov    0x8(%ebp),%eax
 304:	0f b6 00             	movzbl (%eax),%eax
 307:	84 c0                	test   %al,%al
 309:	0f 95 c0             	setne  %al
 30c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 310:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 314:	84 c0                	test   %al,%al
 316:	75 de                	jne    2f6 <strcpy+0xd>
    ;
  return os;
 318:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 31b:	c9                   	leave  
 31c:	c3                   	ret    

0000031d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 31d:	55                   	push   %ebp
 31e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 320:	eb 08                	jmp    32a <strcmp+0xd>
    p++, q++;
 322:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 326:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 32a:	8b 45 08             	mov    0x8(%ebp),%eax
 32d:	0f b6 00             	movzbl (%eax),%eax
 330:	84 c0                	test   %al,%al
 332:	74 10                	je     344 <strcmp+0x27>
 334:	8b 45 08             	mov    0x8(%ebp),%eax
 337:	0f b6 10             	movzbl (%eax),%edx
 33a:	8b 45 0c             	mov    0xc(%ebp),%eax
 33d:	0f b6 00             	movzbl (%eax),%eax
 340:	38 c2                	cmp    %al,%dl
 342:	74 de                	je     322 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 344:	8b 45 08             	mov    0x8(%ebp),%eax
 347:	0f b6 00             	movzbl (%eax),%eax
 34a:	0f b6 d0             	movzbl %al,%edx
 34d:	8b 45 0c             	mov    0xc(%ebp),%eax
 350:	0f b6 00             	movzbl (%eax),%eax
 353:	0f b6 c0             	movzbl %al,%eax
 356:	89 d1                	mov    %edx,%ecx
 358:	29 c1                	sub    %eax,%ecx
 35a:	89 c8                	mov    %ecx,%eax
}
 35c:	5d                   	pop    %ebp
 35d:	c3                   	ret    

0000035e <strlen>:

uint
strlen(char *s)
{
 35e:	55                   	push   %ebp
 35f:	89 e5                	mov    %esp,%ebp
 361:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 364:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 36b:	eb 04                	jmp    371 <strlen+0x13>
 36d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 371:	8b 45 fc             	mov    -0x4(%ebp),%eax
 374:	03 45 08             	add    0x8(%ebp),%eax
 377:	0f b6 00             	movzbl (%eax),%eax
 37a:	84 c0                	test   %al,%al
 37c:	75 ef                	jne    36d <strlen+0xf>
    ;
  return n;
 37e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 381:	c9                   	leave  
 382:	c3                   	ret    

00000383 <memset>:

void*
memset(void *dst, int c, uint n)
{
 383:	55                   	push   %ebp
 384:	89 e5                	mov    %esp,%ebp
 386:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 389:	8b 45 10             	mov    0x10(%ebp),%eax
 38c:	89 44 24 08          	mov    %eax,0x8(%esp)
 390:	8b 45 0c             	mov    0xc(%ebp),%eax
 393:	89 44 24 04          	mov    %eax,0x4(%esp)
 397:	8b 45 08             	mov    0x8(%ebp),%eax
 39a:	89 04 24             	mov    %eax,(%esp)
 39d:	e8 22 ff ff ff       	call   2c4 <stosb>
  return dst;
 3a2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3a5:	c9                   	leave  
 3a6:	c3                   	ret    

000003a7 <strchr>:

char*
strchr(const char *s, char c)
{
 3a7:	55                   	push   %ebp
 3a8:	89 e5                	mov    %esp,%ebp
 3aa:	83 ec 04             	sub    $0x4,%esp
 3ad:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b0:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3b3:	eb 14                	jmp    3c9 <strchr+0x22>
    if(*s == c)
 3b5:	8b 45 08             	mov    0x8(%ebp),%eax
 3b8:	0f b6 00             	movzbl (%eax),%eax
 3bb:	3a 45 fc             	cmp    -0x4(%ebp),%al
 3be:	75 05                	jne    3c5 <strchr+0x1e>
      return (char*)s;
 3c0:	8b 45 08             	mov    0x8(%ebp),%eax
 3c3:	eb 13                	jmp    3d8 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 3c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3c9:	8b 45 08             	mov    0x8(%ebp),%eax
 3cc:	0f b6 00             	movzbl (%eax),%eax
 3cf:	84 c0                	test   %al,%al
 3d1:	75 e2                	jne    3b5 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 3d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3d8:	c9                   	leave  
 3d9:	c3                   	ret    

000003da <gets>:

char*
gets(char *buf, int max)
{
 3da:	55                   	push   %ebp
 3db:	89 e5                	mov    %esp,%ebp
 3dd:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3e7:	eb 44                	jmp    42d <gets+0x53>
    cc = read(0, &c, 1);
 3e9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3f0:	00 
 3f1:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3f4:	89 44 24 04          	mov    %eax,0x4(%esp)
 3f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 3ff:	e8 3c 01 00 00       	call   540 <read>
 404:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 407:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 40b:	7e 2d                	jle    43a <gets+0x60>
      break;
    buf[i++] = c;
 40d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 410:	03 45 08             	add    0x8(%ebp),%eax
 413:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 417:	88 10                	mov    %dl,(%eax)
 419:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 41d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 421:	3c 0a                	cmp    $0xa,%al
 423:	74 16                	je     43b <gets+0x61>
 425:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 429:	3c 0d                	cmp    $0xd,%al
 42b:	74 0e                	je     43b <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 42d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 430:	83 c0 01             	add    $0x1,%eax
 433:	3b 45 0c             	cmp    0xc(%ebp),%eax
 436:	7c b1                	jl     3e9 <gets+0xf>
 438:	eb 01                	jmp    43b <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 43a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 43b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 43e:	03 45 08             	add    0x8(%ebp),%eax
 441:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 444:	8b 45 08             	mov    0x8(%ebp),%eax
}
 447:	c9                   	leave  
 448:	c3                   	ret    

00000449 <stat>:

int
stat(char *n, struct stat *st)
{
 449:	55                   	push   %ebp
 44a:	89 e5                	mov    %esp,%ebp
 44c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 44f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 456:	00 
 457:	8b 45 08             	mov    0x8(%ebp),%eax
 45a:	89 04 24             	mov    %eax,(%esp)
 45d:	e8 06 01 00 00       	call   568 <open>
 462:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 465:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 469:	79 07                	jns    472 <stat+0x29>
    return -1;
 46b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 470:	eb 23                	jmp    495 <stat+0x4c>
  r = fstat(fd, st);
 472:	8b 45 0c             	mov    0xc(%ebp),%eax
 475:	89 44 24 04          	mov    %eax,0x4(%esp)
 479:	8b 45 f4             	mov    -0xc(%ebp),%eax
 47c:	89 04 24             	mov    %eax,(%esp)
 47f:	e8 fc 00 00 00       	call   580 <fstat>
 484:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 487:	8b 45 f4             	mov    -0xc(%ebp),%eax
 48a:	89 04 24             	mov    %eax,(%esp)
 48d:	e8 be 00 00 00       	call   550 <close>
  return r;
 492:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 495:	c9                   	leave  
 496:	c3                   	ret    

00000497 <atoi>:

int
atoi(const char *s)
{
 497:	55                   	push   %ebp
 498:	89 e5                	mov    %esp,%ebp
 49a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 49d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4a4:	eb 23                	jmp    4c9 <atoi+0x32>
    n = n*10 + *s++ - '0';
 4a6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4a9:	89 d0                	mov    %edx,%eax
 4ab:	c1 e0 02             	shl    $0x2,%eax
 4ae:	01 d0                	add    %edx,%eax
 4b0:	01 c0                	add    %eax,%eax
 4b2:	89 c2                	mov    %eax,%edx
 4b4:	8b 45 08             	mov    0x8(%ebp),%eax
 4b7:	0f b6 00             	movzbl (%eax),%eax
 4ba:	0f be c0             	movsbl %al,%eax
 4bd:	01 d0                	add    %edx,%eax
 4bf:	83 e8 30             	sub    $0x30,%eax
 4c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 4c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4c9:	8b 45 08             	mov    0x8(%ebp),%eax
 4cc:	0f b6 00             	movzbl (%eax),%eax
 4cf:	3c 2f                	cmp    $0x2f,%al
 4d1:	7e 0a                	jle    4dd <atoi+0x46>
 4d3:	8b 45 08             	mov    0x8(%ebp),%eax
 4d6:	0f b6 00             	movzbl (%eax),%eax
 4d9:	3c 39                	cmp    $0x39,%al
 4db:	7e c9                	jle    4a6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 4dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4e0:	c9                   	leave  
 4e1:	c3                   	ret    

000004e2 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 4e2:	55                   	push   %ebp
 4e3:	89 e5                	mov    %esp,%ebp
 4e5:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 4e8:	8b 45 08             	mov    0x8(%ebp),%eax
 4eb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4ee:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4f4:	eb 13                	jmp    509 <memmove+0x27>
    *dst++ = *src++;
 4f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 4f9:	0f b6 10             	movzbl (%eax),%edx
 4fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4ff:	88 10                	mov    %dl,(%eax)
 501:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 505:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 509:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 50d:	0f 9f c0             	setg   %al
 510:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 514:	84 c0                	test   %al,%al
 516:	75 de                	jne    4f6 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 518:	8b 45 08             	mov    0x8(%ebp),%eax
}
 51b:	c9                   	leave  
 51c:	c3                   	ret    
 51d:	90                   	nop
 51e:	90                   	nop
 51f:	90                   	nop

00000520 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 520:	b8 01 00 00 00       	mov    $0x1,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <exit>:
SYSCALL(exit)
 528:	b8 02 00 00 00       	mov    $0x2,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <wait>:
SYSCALL(wait)
 530:	b8 03 00 00 00       	mov    $0x3,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <pipe>:
SYSCALL(pipe)
 538:	b8 04 00 00 00       	mov    $0x4,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <read>:
SYSCALL(read)
 540:	b8 05 00 00 00       	mov    $0x5,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <write>:
SYSCALL(write)
 548:	b8 10 00 00 00       	mov    $0x10,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <close>:
SYSCALL(close)
 550:	b8 15 00 00 00       	mov    $0x15,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <kill>:
SYSCALL(kill)
 558:	b8 06 00 00 00       	mov    $0x6,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <exec>:
SYSCALL(exec)
 560:	b8 07 00 00 00       	mov    $0x7,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <open>:
SYSCALL(open)
 568:	b8 0f 00 00 00       	mov    $0xf,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <mknod>:
SYSCALL(mknod)
 570:	b8 11 00 00 00       	mov    $0x11,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <unlink>:
SYSCALL(unlink)
 578:	b8 12 00 00 00       	mov    $0x12,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <fstat>:
SYSCALL(fstat)
 580:	b8 08 00 00 00       	mov    $0x8,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <link>:
SYSCALL(link)
 588:	b8 13 00 00 00       	mov    $0x13,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <mkdir>:
SYSCALL(mkdir)
 590:	b8 14 00 00 00       	mov    $0x14,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <chdir>:
SYSCALL(chdir)
 598:	b8 09 00 00 00       	mov    $0x9,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <dup>:
SYSCALL(dup)
 5a0:	b8 0a 00 00 00       	mov    $0xa,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret    

000005a8 <getpid>:
SYSCALL(getpid)
 5a8:	b8 0b 00 00 00       	mov    $0xb,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret    

000005b0 <sbrk>:
SYSCALL(sbrk)
 5b0:	b8 0c 00 00 00       	mov    $0xc,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret    

000005b8 <sleep>:
SYSCALL(sleep)
 5b8:	b8 0d 00 00 00       	mov    $0xd,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret    

000005c0 <uptime>:
SYSCALL(uptime)
 5c0:	b8 0e 00 00 00       	mov    $0xe,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret    

000005c8 <halt>:
SYSCALL(halt)
 5c8:	b8 16 00 00 00       	mov    $0x16,%eax
 5cd:	cd 40                	int    $0x40
 5cf:	c3                   	ret    

000005d0 <clone>:

SYSCALL(clone)
 5d0:	b8 19 00 00 00       	mov    $0x19,%eax
 5d5:	cd 40                	int    $0x40
 5d7:	c3                   	ret    

000005d8 <join>:
SYSCALL(join)
 5d8:	b8 1a 00 00 00       	mov    $0x1a,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret    

000005e0 <texit>:
SYSCALL(texit)
 5e0:	b8 1b 00 00 00       	mov    $0x1b,%eax
 5e5:	cd 40                	int    $0x40
 5e7:	c3                   	ret    

000005e8 <mutex_init>:
SYSCALL(mutex_init)
 5e8:	b8 1c 00 00 00       	mov    $0x1c,%eax
 5ed:	cd 40                	int    $0x40
 5ef:	c3                   	ret    

000005f0 <mutex_destroy>:
SYSCALL(mutex_destroy)
 5f0:	b8 1d 00 00 00       	mov    $0x1d,%eax
 5f5:	cd 40                	int    $0x40
 5f7:	c3                   	ret    

000005f8 <mutex_lock>:
SYSCALL(mutex_lock)
 5f8:	b8 1e 00 00 00       	mov    $0x1e,%eax
 5fd:	cd 40                	int    $0x40
 5ff:	c3                   	ret    

00000600 <mutex_unlock>:
 600:	b8 1f 00 00 00       	mov    $0x1f,%eax
 605:	cd 40                	int    $0x40
 607:	c3                   	ret    

00000608 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 608:	55                   	push   %ebp
 609:	89 e5                	mov    %esp,%ebp
 60b:	83 ec 28             	sub    $0x28,%esp
 60e:	8b 45 0c             	mov    0xc(%ebp),%eax
 611:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 614:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 61b:	00 
 61c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 61f:	89 44 24 04          	mov    %eax,0x4(%esp)
 623:	8b 45 08             	mov    0x8(%ebp),%eax
 626:	89 04 24             	mov    %eax,(%esp)
 629:	e8 1a ff ff ff       	call   548 <write>
}
 62e:	c9                   	leave  
 62f:	c3                   	ret    

00000630 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 630:	55                   	push   %ebp
 631:	89 e5                	mov    %esp,%ebp
 633:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 636:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 63d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 641:	74 17                	je     65a <printint+0x2a>
 643:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 647:	79 11                	jns    65a <printint+0x2a>
    neg = 1;
 649:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 650:	8b 45 0c             	mov    0xc(%ebp),%eax
 653:	f7 d8                	neg    %eax
 655:	89 45 ec             	mov    %eax,-0x14(%ebp)
 658:	eb 06                	jmp    660 <printint+0x30>
  } else {
    x = xx;
 65a:	8b 45 0c             	mov    0xc(%ebp),%eax
 65d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 660:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 667:	8b 4d 10             	mov    0x10(%ebp),%ecx
 66a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 66d:	ba 00 00 00 00       	mov    $0x0,%edx
 672:	f7 f1                	div    %ecx
 674:	89 d0                	mov    %edx,%eax
 676:	0f b6 90 14 10 00 00 	movzbl 0x1014(%eax),%edx
 67d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 680:	03 45 f4             	add    -0xc(%ebp),%eax
 683:	88 10                	mov    %dl,(%eax)
 685:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 689:	8b 55 10             	mov    0x10(%ebp),%edx
 68c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 68f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 692:	ba 00 00 00 00       	mov    $0x0,%edx
 697:	f7 75 d4             	divl   -0x2c(%ebp)
 69a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 69d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6a1:	75 c4                	jne    667 <printint+0x37>
  if(neg)
 6a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6a7:	74 2a                	je     6d3 <printint+0xa3>
    buf[i++] = '-';
 6a9:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6ac:	03 45 f4             	add    -0xc(%ebp),%eax
 6af:	c6 00 2d             	movb   $0x2d,(%eax)
 6b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 6b6:	eb 1b                	jmp    6d3 <printint+0xa3>
    putc(fd, buf[i]);
 6b8:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6bb:	03 45 f4             	add    -0xc(%ebp),%eax
 6be:	0f b6 00             	movzbl (%eax),%eax
 6c1:	0f be c0             	movsbl %al,%eax
 6c4:	89 44 24 04          	mov    %eax,0x4(%esp)
 6c8:	8b 45 08             	mov    0x8(%ebp),%eax
 6cb:	89 04 24             	mov    %eax,(%esp)
 6ce:	e8 35 ff ff ff       	call   608 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6d3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6db:	79 db                	jns    6b8 <printint+0x88>
    putc(fd, buf[i]);
}
 6dd:	c9                   	leave  
 6de:	c3                   	ret    

000006df <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6df:	55                   	push   %ebp
 6e0:	89 e5                	mov    %esp,%ebp
 6e2:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6e5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6ec:	8d 45 0c             	lea    0xc(%ebp),%eax
 6ef:	83 c0 04             	add    $0x4,%eax
 6f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6f5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6fc:	e9 7d 01 00 00       	jmp    87e <printf+0x19f>
    c = fmt[i] & 0xff;
 701:	8b 55 0c             	mov    0xc(%ebp),%edx
 704:	8b 45 f0             	mov    -0x10(%ebp),%eax
 707:	01 d0                	add    %edx,%eax
 709:	0f b6 00             	movzbl (%eax),%eax
 70c:	0f be c0             	movsbl %al,%eax
 70f:	25 ff 00 00 00       	and    $0xff,%eax
 714:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 717:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 71b:	75 2c                	jne    749 <printf+0x6a>
      if(c == '%'){
 71d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 721:	75 0c                	jne    72f <printf+0x50>
        state = '%';
 723:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 72a:	e9 4b 01 00 00       	jmp    87a <printf+0x19b>
      } else {
        putc(fd, c);
 72f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 732:	0f be c0             	movsbl %al,%eax
 735:	89 44 24 04          	mov    %eax,0x4(%esp)
 739:	8b 45 08             	mov    0x8(%ebp),%eax
 73c:	89 04 24             	mov    %eax,(%esp)
 73f:	e8 c4 fe ff ff       	call   608 <putc>
 744:	e9 31 01 00 00       	jmp    87a <printf+0x19b>
      }
    } else if(state == '%'){
 749:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 74d:	0f 85 27 01 00 00    	jne    87a <printf+0x19b>
      if(c == 'd'){
 753:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 757:	75 2d                	jne    786 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 759:	8b 45 e8             	mov    -0x18(%ebp),%eax
 75c:	8b 00                	mov    (%eax),%eax
 75e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 765:	00 
 766:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 76d:	00 
 76e:	89 44 24 04          	mov    %eax,0x4(%esp)
 772:	8b 45 08             	mov    0x8(%ebp),%eax
 775:	89 04 24             	mov    %eax,(%esp)
 778:	e8 b3 fe ff ff       	call   630 <printint>
        ap++;
 77d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 781:	e9 ed 00 00 00       	jmp    873 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 786:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 78a:	74 06                	je     792 <printf+0xb3>
 78c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 790:	75 2d                	jne    7bf <printf+0xe0>
        printint(fd, *ap, 16, 0);
 792:	8b 45 e8             	mov    -0x18(%ebp),%eax
 795:	8b 00                	mov    (%eax),%eax
 797:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 79e:	00 
 79f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 7a6:	00 
 7a7:	89 44 24 04          	mov    %eax,0x4(%esp)
 7ab:	8b 45 08             	mov    0x8(%ebp),%eax
 7ae:	89 04 24             	mov    %eax,(%esp)
 7b1:	e8 7a fe ff ff       	call   630 <printint>
        ap++;
 7b6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7ba:	e9 b4 00 00 00       	jmp    873 <printf+0x194>
      } else if(c == 's'){
 7bf:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7c3:	75 46                	jne    80b <printf+0x12c>
        s = (char*)*ap;
 7c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7c8:	8b 00                	mov    (%eax),%eax
 7ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7cd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7d5:	75 27                	jne    7fe <printf+0x11f>
          s = "(null)";
 7d7:	c7 45 f4 d0 0c 00 00 	movl   $0xcd0,-0xc(%ebp)
        while(*s != 0){
 7de:	eb 1e                	jmp    7fe <printf+0x11f>
          putc(fd, *s);
 7e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e3:	0f b6 00             	movzbl (%eax),%eax
 7e6:	0f be c0             	movsbl %al,%eax
 7e9:	89 44 24 04          	mov    %eax,0x4(%esp)
 7ed:	8b 45 08             	mov    0x8(%ebp),%eax
 7f0:	89 04 24             	mov    %eax,(%esp)
 7f3:	e8 10 fe ff ff       	call   608 <putc>
          s++;
 7f8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 7fc:	eb 01                	jmp    7ff <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7fe:	90                   	nop
 7ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 802:	0f b6 00             	movzbl (%eax),%eax
 805:	84 c0                	test   %al,%al
 807:	75 d7                	jne    7e0 <printf+0x101>
 809:	eb 68                	jmp    873 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 80b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 80f:	75 1d                	jne    82e <printf+0x14f>
        putc(fd, *ap);
 811:	8b 45 e8             	mov    -0x18(%ebp),%eax
 814:	8b 00                	mov    (%eax),%eax
 816:	0f be c0             	movsbl %al,%eax
 819:	89 44 24 04          	mov    %eax,0x4(%esp)
 81d:	8b 45 08             	mov    0x8(%ebp),%eax
 820:	89 04 24             	mov    %eax,(%esp)
 823:	e8 e0 fd ff ff       	call   608 <putc>
        ap++;
 828:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 82c:	eb 45                	jmp    873 <printf+0x194>
      } else if(c == '%'){
 82e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 832:	75 17                	jne    84b <printf+0x16c>
        putc(fd, c);
 834:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 837:	0f be c0             	movsbl %al,%eax
 83a:	89 44 24 04          	mov    %eax,0x4(%esp)
 83e:	8b 45 08             	mov    0x8(%ebp),%eax
 841:	89 04 24             	mov    %eax,(%esp)
 844:	e8 bf fd ff ff       	call   608 <putc>
 849:	eb 28                	jmp    873 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 84b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 852:	00 
 853:	8b 45 08             	mov    0x8(%ebp),%eax
 856:	89 04 24             	mov    %eax,(%esp)
 859:	e8 aa fd ff ff       	call   608 <putc>
        putc(fd, c);
 85e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 861:	0f be c0             	movsbl %al,%eax
 864:	89 44 24 04          	mov    %eax,0x4(%esp)
 868:	8b 45 08             	mov    0x8(%ebp),%eax
 86b:	89 04 24             	mov    %eax,(%esp)
 86e:	e8 95 fd ff ff       	call   608 <putc>
      }
      state = 0;
 873:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 87a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 87e:	8b 55 0c             	mov    0xc(%ebp),%edx
 881:	8b 45 f0             	mov    -0x10(%ebp),%eax
 884:	01 d0                	add    %edx,%eax
 886:	0f b6 00             	movzbl (%eax),%eax
 889:	84 c0                	test   %al,%al
 88b:	0f 85 70 fe ff ff    	jne    701 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 891:	c9                   	leave  
 892:	c3                   	ret    
 893:	90                   	nop

00000894 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 894:	55                   	push   %ebp
 895:	89 e5                	mov    %esp,%ebp
 897:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 89a:	8b 45 08             	mov    0x8(%ebp),%eax
 89d:	83 e8 08             	sub    $0x8,%eax
 8a0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8a3:	a1 30 10 00 00       	mov    0x1030,%eax
 8a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8ab:	eb 24                	jmp    8d1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b0:	8b 00                	mov    (%eax),%eax
 8b2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8b5:	77 12                	ja     8c9 <free+0x35>
 8b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ba:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8bd:	77 24                	ja     8e3 <free+0x4f>
 8bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c2:	8b 00                	mov    (%eax),%eax
 8c4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8c7:	77 1a                	ja     8e3 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cc:	8b 00                	mov    (%eax),%eax
 8ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8d7:	76 d4                	jbe    8ad <free+0x19>
 8d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8dc:	8b 00                	mov    (%eax),%eax
 8de:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8e1:	76 ca                	jbe    8ad <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 8e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e6:	8b 40 04             	mov    0x4(%eax),%eax
 8e9:	c1 e0 03             	shl    $0x3,%eax
 8ec:	89 c2                	mov    %eax,%edx
 8ee:	03 55 f8             	add    -0x8(%ebp),%edx
 8f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f4:	8b 00                	mov    (%eax),%eax
 8f6:	39 c2                	cmp    %eax,%edx
 8f8:	75 24                	jne    91e <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 8fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8fd:	8b 50 04             	mov    0x4(%eax),%edx
 900:	8b 45 fc             	mov    -0x4(%ebp),%eax
 903:	8b 00                	mov    (%eax),%eax
 905:	8b 40 04             	mov    0x4(%eax),%eax
 908:	01 c2                	add    %eax,%edx
 90a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 90d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 910:	8b 45 fc             	mov    -0x4(%ebp),%eax
 913:	8b 00                	mov    (%eax),%eax
 915:	8b 10                	mov    (%eax),%edx
 917:	8b 45 f8             	mov    -0x8(%ebp),%eax
 91a:	89 10                	mov    %edx,(%eax)
 91c:	eb 0a                	jmp    928 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 91e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 921:	8b 10                	mov    (%eax),%edx
 923:	8b 45 f8             	mov    -0x8(%ebp),%eax
 926:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 928:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92b:	8b 40 04             	mov    0x4(%eax),%eax
 92e:	c1 e0 03             	shl    $0x3,%eax
 931:	03 45 fc             	add    -0x4(%ebp),%eax
 934:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 937:	75 20                	jne    959 <free+0xc5>
    p->s.size += bp->s.size;
 939:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93c:	8b 50 04             	mov    0x4(%eax),%edx
 93f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 942:	8b 40 04             	mov    0x4(%eax),%eax
 945:	01 c2                	add    %eax,%edx
 947:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 94d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 950:	8b 10                	mov    (%eax),%edx
 952:	8b 45 fc             	mov    -0x4(%ebp),%eax
 955:	89 10                	mov    %edx,(%eax)
 957:	eb 08                	jmp    961 <free+0xcd>
  } else
    p->s.ptr = bp;
 959:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 95f:	89 10                	mov    %edx,(%eax)
  freep = p;
 961:	8b 45 fc             	mov    -0x4(%ebp),%eax
 964:	a3 30 10 00 00       	mov    %eax,0x1030
}
 969:	c9                   	leave  
 96a:	c3                   	ret    

0000096b <morecore>:

static Header*
morecore(uint nu)
{
 96b:	55                   	push   %ebp
 96c:	89 e5                	mov    %esp,%ebp
 96e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 971:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 978:	77 07                	ja     981 <morecore+0x16>
    nu = 4096;
 97a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 981:	8b 45 08             	mov    0x8(%ebp),%eax
 984:	c1 e0 03             	shl    $0x3,%eax
 987:	89 04 24             	mov    %eax,(%esp)
 98a:	e8 21 fc ff ff       	call   5b0 <sbrk>
 98f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 992:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 996:	75 07                	jne    99f <morecore+0x34>
    return 0;
 998:	b8 00 00 00 00       	mov    $0x0,%eax
 99d:	eb 22                	jmp    9c1 <morecore+0x56>
  hp = (Header*)p;
 99f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a8:	8b 55 08             	mov    0x8(%ebp),%edx
 9ab:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9b1:	83 c0 08             	add    $0x8,%eax
 9b4:	89 04 24             	mov    %eax,(%esp)
 9b7:	e8 d8 fe ff ff       	call   894 <free>
  return freep;
 9bc:	a1 30 10 00 00       	mov    0x1030,%eax
}
 9c1:	c9                   	leave  
 9c2:	c3                   	ret    

000009c3 <malloc>:

void*
malloc(uint nbytes)
{
 9c3:	55                   	push   %ebp
 9c4:	89 e5                	mov    %esp,%ebp
 9c6:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9c9:	8b 45 08             	mov    0x8(%ebp),%eax
 9cc:	83 c0 07             	add    $0x7,%eax
 9cf:	c1 e8 03             	shr    $0x3,%eax
 9d2:	83 c0 01             	add    $0x1,%eax
 9d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9d8:	a1 30 10 00 00       	mov    0x1030,%eax
 9dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9e4:	75 23                	jne    a09 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9e6:	c7 45 f0 28 10 00 00 	movl   $0x1028,-0x10(%ebp)
 9ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9f0:	a3 30 10 00 00       	mov    %eax,0x1030
 9f5:	a1 30 10 00 00       	mov    0x1030,%eax
 9fa:	a3 28 10 00 00       	mov    %eax,0x1028
    base.s.size = 0;
 9ff:	c7 05 2c 10 00 00 00 	movl   $0x0,0x102c
 a06:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a0c:	8b 00                	mov    (%eax),%eax
 a0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a14:	8b 40 04             	mov    0x4(%eax),%eax
 a17:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a1a:	72 4d                	jb     a69 <malloc+0xa6>
      if(p->s.size == nunits)
 a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1f:	8b 40 04             	mov    0x4(%eax),%eax
 a22:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a25:	75 0c                	jne    a33 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a2a:	8b 10                	mov    (%eax),%edx
 a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a2f:	89 10                	mov    %edx,(%eax)
 a31:	eb 26                	jmp    a59 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a36:	8b 40 04             	mov    0x4(%eax),%eax
 a39:	89 c2                	mov    %eax,%edx
 a3b:	2b 55 ec             	sub    -0x14(%ebp),%edx
 a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a41:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a47:	8b 40 04             	mov    0x4(%eax),%eax
 a4a:	c1 e0 03             	shl    $0x3,%eax
 a4d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a53:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a56:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a5c:	a3 30 10 00 00       	mov    %eax,0x1030
      return (void*)(p + 1);
 a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a64:	83 c0 08             	add    $0x8,%eax
 a67:	eb 38                	jmp    aa1 <malloc+0xde>
    }
    if(p == freep)
 a69:	a1 30 10 00 00       	mov    0x1030,%eax
 a6e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a71:	75 1b                	jne    a8e <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a73:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a76:	89 04 24             	mov    %eax,(%esp)
 a79:	e8 ed fe ff ff       	call   96b <morecore>
 a7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a81:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a85:	75 07                	jne    a8e <malloc+0xcb>
        return 0;
 a87:	b8 00 00 00 00       	mov    $0x0,%eax
 a8c:	eb 13                	jmp    aa1 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a91:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a97:	8b 00                	mov    (%eax),%eax
 a99:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a9c:	e9 70 ff ff ff       	jmp    a11 <malloc+0x4e>
}
 aa1:	c9                   	leave  
 aa2:	c3                   	ret    
 aa3:	90                   	nop

00000aa4 <pthread_create>:
	clone's 3rd argument, *stek, should be allocated here?
*/

#define PAGESIZE (4096)  //Maybe 4092??

int pthread_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine) (void*), void *arg){
 aa4:	55                   	push   %ebp
 aa5:	89 e5                	mov    %esp,%ebp
 aa7:	83 ec 28             	sub    $0x28,%esp

	void *mystek = malloc((uint)PAGESIZE*2); //Why do we need the *2?
 aaa:	c7 04 24 00 20 00 00 	movl   $0x2000,(%esp)
 ab1:	e8 0d ff ff ff       	call   9c3 <malloc>
 ab6:	89 45 f4             	mov    %eax,-0xc(%ebp)
//zzddhhtjzz/xv6/blob/master
	if((uint)mystek % PAGESIZE){
 ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abc:	25 ff 0f 00 00       	and    $0xfff,%eax
 ac1:	85 c0                	test   %eax,%eax
 ac3:	74 15                	je     ada <pthread_create+0x36>
		mystek += 4096 - ((uint)mystek % PAGESIZE);
 ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac8:	89 c2                	mov    %eax,%edx
 aca:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
 ad0:	b8 00 10 00 00       	mov    $0x1000,%eax
 ad5:	29 d0                	sub    %edx,%eax
 ad7:	01 45 f4             	add    %eax,-0xc(%ebp)
	}
	thread->pid = clone(start_routine, arg, mystek);
 ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
 add:	89 44 24 08          	mov    %eax,0x8(%esp)
 ae1:	8b 45 14             	mov    0x14(%ebp),%eax
 ae4:	89 44 24 04          	mov    %eax,0x4(%esp)
 ae8:	8b 45 10             	mov    0x10(%ebp),%eax
 aeb:	89 04 24             	mov    %eax,(%esp)
 aee:	e8 dd fa ff ff       	call   5d0 <clone>
 af3:	8b 55 08             	mov    0x8(%ebp),%edx
 af6:	89 02                	mov    %eax,(%edx)
	return thread->pid;
 af8:	8b 45 08             	mov    0x8(%ebp),%eax
 afb:	8b 00                	mov    (%eax),%eax
}
 afd:	c9                   	leave  
 afe:	c3                   	ret    

00000aff <pthread_join>:

int pthread_join(pthread_t thread, void **retval){
 aff:	55                   	push   %ebp
 b00:	89 e5                	mov    %esp,%ebp
 b02:	83 ec 28             	sub    $0x28,%esp

	void *stek;

	join((int)thread.pid, &stek, (void*)retval);
 b05:	8b 45 08             	mov    0x8(%ebp),%eax
 b08:	8b 55 0c             	mov    0xc(%ebp),%edx
 b0b:	89 54 24 08          	mov    %edx,0x8(%esp)
 b0f:	8d 55 f4             	lea    -0xc(%ebp),%edx
 b12:	89 54 24 04          	mov    %edx,0x4(%esp)
 b16:	89 04 24             	mov    %eax,(%esp)
 b19:	e8 ba fa ff ff       	call   5d8 <join>

	free(stek);
 b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b21:	89 04 24             	mov    %eax,(%esp)
 b24:	e8 6b fd ff ff       	call   894 <free>

	return 0;
 b29:	b8 00 00 00 00       	mov    $0x0,%eax
}
 b2e:	c9                   	leave  
 b2f:	c3                   	ret    

00000b30 <pthread_exit>:

int pthread_exit(void *retval){
 b30:	55                   	push   %ebp
 b31:	89 e5                	mov    %esp,%ebp
 b33:	83 ec 18             	sub    $0x18,%esp

	texit(retval);
 b36:	8b 45 08             	mov    0x8(%ebp),%eax
 b39:	89 04 24             	mov    %eax,(%esp)
 b3c:	e8 9f fa ff ff       	call   5e0 <texit>

	return 0;
 b41:	b8 00 00 00 00       	mov    $0x0,%eax
}
 b46:	c9                   	leave  
 b47:	c3                   	ret    

00000b48 <pthread_mutex_init>:


int pthread_mutex_init(pthread_mutex_t *mutex, const pthread_mutex_attr_t *attr){
 b48:	55                   	push   %ebp
 b49:	89 e5                	mov    %esp,%ebp
 b4b:	83 ec 18             	sub    $0x18,%esp

	int mid = mutex_init();
 b4e:	e8 95 fa ff ff       	call   5e8 <mutex_init>
 b53:	89 45 f4             	mov    %eax,-0xc(%ebp)

	//returns the id of the initalized mutex
	return mid;
 b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
 b59:	c9                   	leave  
 b5a:	c3                   	ret    

00000b5b <pthread_mutex_destroy>:


int pthread_mutex_destroy(pthread_mutex_t *mutex){
 b5b:	55                   	push   %ebp
 b5c:	89 e5                	mov    %esp,%ebp
 b5e:	83 ec 18             	sub    $0x18,%esp

	//flag this mutex as destroyed
	mutex_destroy(mutex->mid);
 b61:	8b 45 08             	mov    0x8(%ebp),%eax
 b64:	8b 40 04             	mov    0x4(%eax),%eax
 b67:	89 04 24             	mov    %eax,(%esp)
 b6a:	e8 81 fa ff ff       	call   5f0 <mutex_destroy>
	return 0;
 b6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 b74:	c9                   	leave  
 b75:	c3                   	ret    

00000b76 <pthread_mutex_lock>:


int pthread_mutex_lock(pthread_mutex_t *mutex){
 b76:	55                   	push   %ebp
 b77:	89 e5                	mov    %esp,%ebp
 b79:	83 ec 18             	sub    $0x18,%esp

	mutex_lock(mutex->mid);
 b7c:	8b 45 08             	mov    0x8(%ebp),%eax
 b7f:	8b 40 04             	mov    0x4(%eax),%eax
 b82:	89 04 24             	mov    %eax,(%esp)
 b85:	e8 6e fa ff ff       	call   5f8 <mutex_lock>
	return 0;
 b8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 b8f:	c9                   	leave  
 b90:	c3                   	ret    

00000b91 <pthread_mutex_unlock>:


int pthread_mutex_unlock(pthread_mutex_t *mutex){
 b91:	55                   	push   %ebp
 b92:	89 e5                	mov    %esp,%ebp
 b94:	83 ec 18             	sub    $0x18,%esp

	mutex_unlock(mutex->mid);
 b97:	8b 45 08             	mov    0x8(%ebp),%eax
 b9a:	8b 40 04             	mov    0x4(%eax),%eax
 b9d:	89 04 24             	mov    %eax,(%esp)
 ba0:	e8 5b fa ff ff       	call   600 <mutex_unlock>
	return 0;
 ba5:	b8 00 00 00 00       	mov    $0x0,%eax
 baa:	c9                   	leave  
 bab:	c3                   	ret    
