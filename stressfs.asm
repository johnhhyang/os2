
_stressfs:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "fs.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	81 ec 30 02 00 00    	sub    $0x230,%esp
  int fd, i;
  char path[] = "stressfs0";
   c:	c7 84 24 1e 02 00 00 	movl   $0x65727473,0x21e(%esp)
  13:	73 74 72 65 
  17:	c7 84 24 22 02 00 00 	movl   $0x73667373,0x222(%esp)
  1e:	73 73 66 73 
  22:	66 c7 84 24 26 02 00 	movw   $0x30,0x226(%esp)
  29:	00 30 00 
  char data[512];

  printf(1, "stressfs starting\n");
  2c:	c7 44 24 04 9c 0a 00 	movl   $0xa9c,0x4(%esp)
  33:	00 
  34:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  3b:	e8 8f 05 00 00       	call   5cf <printf>
  memset(data, 'a', sizeof(data));
  40:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  47:	00 
  48:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  4f:	00 
  50:	8d 44 24 1e          	lea    0x1e(%esp),%eax
  54:	89 04 24             	mov    %eax,(%esp)
  57:	e8 17 02 00 00       	call   273 <memset>

  for(i = 0; i < 4; i++)
  5c:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
  63:	00 00 00 00 
  67:	eb 11                	jmp    7a <main+0x7a>
    if(fork() > 0)
  69:	e8 a2 03 00 00       	call   410 <fork>
  6e:	85 c0                	test   %eax,%eax
  70:	7f 14                	jg     86 <main+0x86>
  char data[512];

  printf(1, "stressfs starting\n");
  memset(data, 'a', sizeof(data));

  for(i = 0; i < 4; i++)
  72:	83 84 24 2c 02 00 00 	addl   $0x1,0x22c(%esp)
  79:	01 
  7a:	83 bc 24 2c 02 00 00 	cmpl   $0x3,0x22c(%esp)
  81:	03 
  82:	7e e5                	jle    69 <main+0x69>
  84:	eb 01                	jmp    87 <main+0x87>
    if(fork() > 0)
      break;
  86:	90                   	nop

  printf(1, "write %d\n", i);
  87:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
  8e:	89 44 24 08          	mov    %eax,0x8(%esp)
  92:	c7 44 24 04 af 0a 00 	movl   $0xaaf,0x4(%esp)
  99:	00 
  9a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a1:	e8 29 05 00 00       	call   5cf <printf>

  path[8] += i;
  a6:	0f b6 84 24 26 02 00 	movzbl 0x226(%esp),%eax
  ad:	00 
  ae:	89 c2                	mov    %eax,%edx
  b0:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
  b7:	01 d0                	add    %edx,%eax
  b9:	88 84 24 26 02 00 00 	mov    %al,0x226(%esp)
  fd = open(path, O_CREATE | O_RDWR);
  c0:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  c7:	00 
  c8:	8d 84 24 1e 02 00 00 	lea    0x21e(%esp),%eax
  cf:	89 04 24             	mov    %eax,(%esp)
  d2:	e8 81 03 00 00       	call   458 <open>
  d7:	89 84 24 28 02 00 00 	mov    %eax,0x228(%esp)
  for(i = 0; i < 20; i++)
  de:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
  e5:	00 00 00 00 
  e9:	eb 27                	jmp    112 <main+0x112>
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  eb:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  f2:	00 
  f3:	8d 44 24 1e          	lea    0x1e(%esp),%eax
  f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  fb:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 102:	89 04 24             	mov    %eax,(%esp)
 105:	e8 2e 03 00 00       	call   438 <write>

  printf(1, "write %d\n", i);

  path[8] += i;
  fd = open(path, O_CREATE | O_RDWR);
  for(i = 0; i < 20; i++)
 10a:	83 84 24 2c 02 00 00 	addl   $0x1,0x22c(%esp)
 111:	01 
 112:	83 bc 24 2c 02 00 00 	cmpl   $0x13,0x22c(%esp)
 119:	13 
 11a:	7e cf                	jle    eb <main+0xeb>
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  close(fd);
 11c:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 123:	89 04 24             	mov    %eax,(%esp)
 126:	e8 15 03 00 00       	call   440 <close>

  printf(1, "read\n");
 12b:	c7 44 24 04 b9 0a 00 	movl   $0xab9,0x4(%esp)
 132:	00 
 133:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 13a:	e8 90 04 00 00       	call   5cf <printf>

  fd = open(path, O_RDONLY);
 13f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 146:	00 
 147:	8d 84 24 1e 02 00 00 	lea    0x21e(%esp),%eax
 14e:	89 04 24             	mov    %eax,(%esp)
 151:	e8 02 03 00 00       	call   458 <open>
 156:	89 84 24 28 02 00 00 	mov    %eax,0x228(%esp)
  for (i = 0; i < 20; i++)
 15d:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
 164:	00 00 00 00 
 168:	eb 27                	jmp    191 <main+0x191>
    read(fd, data, sizeof(data));
 16a:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
 171:	00 
 172:	8d 44 24 1e          	lea    0x1e(%esp),%eax
 176:	89 44 24 04          	mov    %eax,0x4(%esp)
 17a:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 181:	89 04 24             	mov    %eax,(%esp)
 184:	e8 a7 02 00 00       	call   430 <read>
  close(fd);

  printf(1, "read\n");

  fd = open(path, O_RDONLY);
  for (i = 0; i < 20; i++)
 189:	83 84 24 2c 02 00 00 	addl   $0x1,0x22c(%esp)
 190:	01 
 191:	83 bc 24 2c 02 00 00 	cmpl   $0x13,0x22c(%esp)
 198:	13 
 199:	7e cf                	jle    16a <main+0x16a>
    read(fd, data, sizeof(data));
  close(fd);
 19b:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 1a2:	89 04 24             	mov    %eax,(%esp)
 1a5:	e8 96 02 00 00       	call   440 <close>

  wait();
 1aa:	e8 71 02 00 00       	call   420 <wait>
  
  exit();
 1af:	e8 64 02 00 00       	call   418 <exit>

000001b4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1b4:	55                   	push   %ebp
 1b5:	89 e5                	mov    %esp,%ebp
 1b7:	57                   	push   %edi
 1b8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1bc:	8b 55 10             	mov    0x10(%ebp),%edx
 1bf:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c2:	89 cb                	mov    %ecx,%ebx
 1c4:	89 df                	mov    %ebx,%edi
 1c6:	89 d1                	mov    %edx,%ecx
 1c8:	fc                   	cld    
 1c9:	f3 aa                	rep stos %al,%es:(%edi)
 1cb:	89 ca                	mov    %ecx,%edx
 1cd:	89 fb                	mov    %edi,%ebx
 1cf:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1d2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1d5:	5b                   	pop    %ebx
 1d6:	5f                   	pop    %edi
 1d7:	5d                   	pop    %ebp
 1d8:	c3                   	ret    

000001d9 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1d9:	55                   	push   %ebp
 1da:	89 e5                	mov    %esp,%ebp
 1dc:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1df:	8b 45 08             	mov    0x8(%ebp),%eax
 1e2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1e5:	90                   	nop
 1e6:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e9:	0f b6 10             	movzbl (%eax),%edx
 1ec:	8b 45 08             	mov    0x8(%ebp),%eax
 1ef:	88 10                	mov    %dl,(%eax)
 1f1:	8b 45 08             	mov    0x8(%ebp),%eax
 1f4:	0f b6 00             	movzbl (%eax),%eax
 1f7:	84 c0                	test   %al,%al
 1f9:	0f 95 c0             	setne  %al
 1fc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 200:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 204:	84 c0                	test   %al,%al
 206:	75 de                	jne    1e6 <strcpy+0xd>
    ;
  return os;
 208:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 20b:	c9                   	leave  
 20c:	c3                   	ret    

0000020d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 20d:	55                   	push   %ebp
 20e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 210:	eb 08                	jmp    21a <strcmp+0xd>
    p++, q++;
 212:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 216:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 21a:	8b 45 08             	mov    0x8(%ebp),%eax
 21d:	0f b6 00             	movzbl (%eax),%eax
 220:	84 c0                	test   %al,%al
 222:	74 10                	je     234 <strcmp+0x27>
 224:	8b 45 08             	mov    0x8(%ebp),%eax
 227:	0f b6 10             	movzbl (%eax),%edx
 22a:	8b 45 0c             	mov    0xc(%ebp),%eax
 22d:	0f b6 00             	movzbl (%eax),%eax
 230:	38 c2                	cmp    %al,%dl
 232:	74 de                	je     212 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 234:	8b 45 08             	mov    0x8(%ebp),%eax
 237:	0f b6 00             	movzbl (%eax),%eax
 23a:	0f b6 d0             	movzbl %al,%edx
 23d:	8b 45 0c             	mov    0xc(%ebp),%eax
 240:	0f b6 00             	movzbl (%eax),%eax
 243:	0f b6 c0             	movzbl %al,%eax
 246:	89 d1                	mov    %edx,%ecx
 248:	29 c1                	sub    %eax,%ecx
 24a:	89 c8                	mov    %ecx,%eax
}
 24c:	5d                   	pop    %ebp
 24d:	c3                   	ret    

0000024e <strlen>:

uint
strlen(char *s)
{
 24e:	55                   	push   %ebp
 24f:	89 e5                	mov    %esp,%ebp
 251:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 254:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 25b:	eb 04                	jmp    261 <strlen+0x13>
 25d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 261:	8b 45 fc             	mov    -0x4(%ebp),%eax
 264:	03 45 08             	add    0x8(%ebp),%eax
 267:	0f b6 00             	movzbl (%eax),%eax
 26a:	84 c0                	test   %al,%al
 26c:	75 ef                	jne    25d <strlen+0xf>
    ;
  return n;
 26e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 271:	c9                   	leave  
 272:	c3                   	ret    

00000273 <memset>:

void*
memset(void *dst, int c, uint n)
{
 273:	55                   	push   %ebp
 274:	89 e5                	mov    %esp,%ebp
 276:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 279:	8b 45 10             	mov    0x10(%ebp),%eax
 27c:	89 44 24 08          	mov    %eax,0x8(%esp)
 280:	8b 45 0c             	mov    0xc(%ebp),%eax
 283:	89 44 24 04          	mov    %eax,0x4(%esp)
 287:	8b 45 08             	mov    0x8(%ebp),%eax
 28a:	89 04 24             	mov    %eax,(%esp)
 28d:	e8 22 ff ff ff       	call   1b4 <stosb>
  return dst;
 292:	8b 45 08             	mov    0x8(%ebp),%eax
}
 295:	c9                   	leave  
 296:	c3                   	ret    

00000297 <strchr>:

char*
strchr(const char *s, char c)
{
 297:	55                   	push   %ebp
 298:	89 e5                	mov    %esp,%ebp
 29a:	83 ec 04             	sub    $0x4,%esp
 29d:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a0:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2a3:	eb 14                	jmp    2b9 <strchr+0x22>
    if(*s == c)
 2a5:	8b 45 08             	mov    0x8(%ebp),%eax
 2a8:	0f b6 00             	movzbl (%eax),%eax
 2ab:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2ae:	75 05                	jne    2b5 <strchr+0x1e>
      return (char*)s;
 2b0:	8b 45 08             	mov    0x8(%ebp),%eax
 2b3:	eb 13                	jmp    2c8 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2b5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2b9:	8b 45 08             	mov    0x8(%ebp),%eax
 2bc:	0f b6 00             	movzbl (%eax),%eax
 2bf:	84 c0                	test   %al,%al
 2c1:	75 e2                	jne    2a5 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2c8:	c9                   	leave  
 2c9:	c3                   	ret    

000002ca <gets>:

char*
gets(char *buf, int max)
{
 2ca:	55                   	push   %ebp
 2cb:	89 e5                	mov    %esp,%ebp
 2cd:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2d7:	eb 44                	jmp    31d <gets+0x53>
    cc = read(0, &c, 1);
 2d9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2e0:	00 
 2e1:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2e4:	89 44 24 04          	mov    %eax,0x4(%esp)
 2e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2ef:	e8 3c 01 00 00       	call   430 <read>
 2f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2fb:	7e 2d                	jle    32a <gets+0x60>
      break;
    buf[i++] = c;
 2fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 300:	03 45 08             	add    0x8(%ebp),%eax
 303:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 307:	88 10                	mov    %dl,(%eax)
 309:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 30d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 311:	3c 0a                	cmp    $0xa,%al
 313:	74 16                	je     32b <gets+0x61>
 315:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 319:	3c 0d                	cmp    $0xd,%al
 31b:	74 0e                	je     32b <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 31d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 320:	83 c0 01             	add    $0x1,%eax
 323:	3b 45 0c             	cmp    0xc(%ebp),%eax
 326:	7c b1                	jl     2d9 <gets+0xf>
 328:	eb 01                	jmp    32b <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 32a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 32b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 32e:	03 45 08             	add    0x8(%ebp),%eax
 331:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 334:	8b 45 08             	mov    0x8(%ebp),%eax
}
 337:	c9                   	leave  
 338:	c3                   	ret    

00000339 <stat>:

int
stat(char *n, struct stat *st)
{
 339:	55                   	push   %ebp
 33a:	89 e5                	mov    %esp,%ebp
 33c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 33f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 346:	00 
 347:	8b 45 08             	mov    0x8(%ebp),%eax
 34a:	89 04 24             	mov    %eax,(%esp)
 34d:	e8 06 01 00 00       	call   458 <open>
 352:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 355:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 359:	79 07                	jns    362 <stat+0x29>
    return -1;
 35b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 360:	eb 23                	jmp    385 <stat+0x4c>
  r = fstat(fd, st);
 362:	8b 45 0c             	mov    0xc(%ebp),%eax
 365:	89 44 24 04          	mov    %eax,0x4(%esp)
 369:	8b 45 f4             	mov    -0xc(%ebp),%eax
 36c:	89 04 24             	mov    %eax,(%esp)
 36f:	e8 fc 00 00 00       	call   470 <fstat>
 374:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 377:	8b 45 f4             	mov    -0xc(%ebp),%eax
 37a:	89 04 24             	mov    %eax,(%esp)
 37d:	e8 be 00 00 00       	call   440 <close>
  return r;
 382:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 385:	c9                   	leave  
 386:	c3                   	ret    

00000387 <atoi>:

int
atoi(const char *s)
{
 387:	55                   	push   %ebp
 388:	89 e5                	mov    %esp,%ebp
 38a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 38d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 394:	eb 23                	jmp    3b9 <atoi+0x32>
    n = n*10 + *s++ - '0';
 396:	8b 55 fc             	mov    -0x4(%ebp),%edx
 399:	89 d0                	mov    %edx,%eax
 39b:	c1 e0 02             	shl    $0x2,%eax
 39e:	01 d0                	add    %edx,%eax
 3a0:	01 c0                	add    %eax,%eax
 3a2:	89 c2                	mov    %eax,%edx
 3a4:	8b 45 08             	mov    0x8(%ebp),%eax
 3a7:	0f b6 00             	movzbl (%eax),%eax
 3aa:	0f be c0             	movsbl %al,%eax
 3ad:	01 d0                	add    %edx,%eax
 3af:	83 e8 30             	sub    $0x30,%eax
 3b2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 3b5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3b9:	8b 45 08             	mov    0x8(%ebp),%eax
 3bc:	0f b6 00             	movzbl (%eax),%eax
 3bf:	3c 2f                	cmp    $0x2f,%al
 3c1:	7e 0a                	jle    3cd <atoi+0x46>
 3c3:	8b 45 08             	mov    0x8(%ebp),%eax
 3c6:	0f b6 00             	movzbl (%eax),%eax
 3c9:	3c 39                	cmp    $0x39,%al
 3cb:	7e c9                	jle    396 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3d0:	c9                   	leave  
 3d1:	c3                   	ret    

000003d2 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3d2:	55                   	push   %ebp
 3d3:	89 e5                	mov    %esp,%ebp
 3d5:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3d8:	8b 45 08             	mov    0x8(%ebp),%eax
 3db:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3de:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3e4:	eb 13                	jmp    3f9 <memmove+0x27>
    *dst++ = *src++;
 3e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3e9:	0f b6 10             	movzbl (%eax),%edx
 3ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3ef:	88 10                	mov    %dl,(%eax)
 3f1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3f5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 3f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3fd:	0f 9f c0             	setg   %al
 400:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 404:	84 c0                	test   %al,%al
 406:	75 de                	jne    3e6 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 408:	8b 45 08             	mov    0x8(%ebp),%eax
}
 40b:	c9                   	leave  
 40c:	c3                   	ret    
 40d:	90                   	nop
 40e:	90                   	nop
 40f:	90                   	nop

00000410 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 410:	b8 01 00 00 00       	mov    $0x1,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <exit>:
SYSCALL(exit)
 418:	b8 02 00 00 00       	mov    $0x2,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <wait>:
SYSCALL(wait)
 420:	b8 03 00 00 00       	mov    $0x3,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <pipe>:
SYSCALL(pipe)
 428:	b8 04 00 00 00       	mov    $0x4,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <read>:
SYSCALL(read)
 430:	b8 05 00 00 00       	mov    $0x5,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <write>:
SYSCALL(write)
 438:	b8 10 00 00 00       	mov    $0x10,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <close>:
SYSCALL(close)
 440:	b8 15 00 00 00       	mov    $0x15,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <kill>:
SYSCALL(kill)
 448:	b8 06 00 00 00       	mov    $0x6,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <exec>:
SYSCALL(exec)
 450:	b8 07 00 00 00       	mov    $0x7,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <open>:
SYSCALL(open)
 458:	b8 0f 00 00 00       	mov    $0xf,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <mknod>:
SYSCALL(mknod)
 460:	b8 11 00 00 00       	mov    $0x11,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <unlink>:
SYSCALL(unlink)
 468:	b8 12 00 00 00       	mov    $0x12,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <fstat>:
SYSCALL(fstat)
 470:	b8 08 00 00 00       	mov    $0x8,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <link>:
SYSCALL(link)
 478:	b8 13 00 00 00       	mov    $0x13,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <mkdir>:
SYSCALL(mkdir)
 480:	b8 14 00 00 00       	mov    $0x14,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <chdir>:
SYSCALL(chdir)
 488:	b8 09 00 00 00       	mov    $0x9,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <dup>:
SYSCALL(dup)
 490:	b8 0a 00 00 00       	mov    $0xa,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <getpid>:
SYSCALL(getpid)
 498:	b8 0b 00 00 00       	mov    $0xb,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <sbrk>:
SYSCALL(sbrk)
 4a0:	b8 0c 00 00 00       	mov    $0xc,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <sleep>:
SYSCALL(sleep)
 4a8:	b8 0d 00 00 00       	mov    $0xd,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <uptime>:
SYSCALL(uptime)
 4b0:	b8 0e 00 00 00       	mov    $0xe,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <halt>:
SYSCALL(halt)
 4b8:	b8 16 00 00 00       	mov    $0x16,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <clone>:

SYSCALL(clone)
 4c0:	b8 19 00 00 00       	mov    $0x19,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <join>:
SYSCALL(join)
 4c8:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <texit>:
SYSCALL(texit)
 4d0:	b8 1b 00 00 00       	mov    $0x1b,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <mutex_init>:
SYSCALL(mutex_init)
 4d8:	b8 1c 00 00 00       	mov    $0x1c,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <mutex_destroy>:
SYSCALL(mutex_destroy)
 4e0:	b8 1d 00 00 00       	mov    $0x1d,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <mutex_lock>:
SYSCALL(mutex_lock)
 4e8:	b8 1e 00 00 00       	mov    $0x1e,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <mutex_unlock>:
 4f0:	b8 1f 00 00 00       	mov    $0x1f,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4f8:	55                   	push   %ebp
 4f9:	89 e5                	mov    %esp,%ebp
 4fb:	83 ec 28             	sub    $0x28,%esp
 4fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 501:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 504:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 50b:	00 
 50c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 50f:	89 44 24 04          	mov    %eax,0x4(%esp)
 513:	8b 45 08             	mov    0x8(%ebp),%eax
 516:	89 04 24             	mov    %eax,(%esp)
 519:	e8 1a ff ff ff       	call   438 <write>
}
 51e:	c9                   	leave  
 51f:	c3                   	ret    

00000520 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 520:	55                   	push   %ebp
 521:	89 e5                	mov    %esp,%ebp
 523:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 526:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 52d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 531:	74 17                	je     54a <printint+0x2a>
 533:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 537:	79 11                	jns    54a <printint+0x2a>
    neg = 1;
 539:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 540:	8b 45 0c             	mov    0xc(%ebp),%eax
 543:	f7 d8                	neg    %eax
 545:	89 45 ec             	mov    %eax,-0x14(%ebp)
 548:	eb 06                	jmp    550 <printint+0x30>
  } else {
    x = xx;
 54a:	8b 45 0c             	mov    0xc(%ebp),%eax
 54d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 550:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 557:	8b 4d 10             	mov    0x10(%ebp),%ecx
 55a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 55d:	ba 00 00 00 00       	mov    $0x0,%edx
 562:	f7 f1                	div    %ecx
 564:	89 d0                	mov    %edx,%eax
 566:	0f b6 90 e4 0d 00 00 	movzbl 0xde4(%eax),%edx
 56d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 570:	03 45 f4             	add    -0xc(%ebp),%eax
 573:	88 10                	mov    %dl,(%eax)
 575:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 579:	8b 55 10             	mov    0x10(%ebp),%edx
 57c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 57f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 582:	ba 00 00 00 00       	mov    $0x0,%edx
 587:	f7 75 d4             	divl   -0x2c(%ebp)
 58a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 58d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 591:	75 c4                	jne    557 <printint+0x37>
  if(neg)
 593:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 597:	74 2a                	je     5c3 <printint+0xa3>
    buf[i++] = '-';
 599:	8d 45 dc             	lea    -0x24(%ebp),%eax
 59c:	03 45 f4             	add    -0xc(%ebp),%eax
 59f:	c6 00 2d             	movb   $0x2d,(%eax)
 5a2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 5a6:	eb 1b                	jmp    5c3 <printint+0xa3>
    putc(fd, buf[i]);
 5a8:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5ab:	03 45 f4             	add    -0xc(%ebp),%eax
 5ae:	0f b6 00             	movzbl (%eax),%eax
 5b1:	0f be c0             	movsbl %al,%eax
 5b4:	89 44 24 04          	mov    %eax,0x4(%esp)
 5b8:	8b 45 08             	mov    0x8(%ebp),%eax
 5bb:	89 04 24             	mov    %eax,(%esp)
 5be:	e8 35 ff ff ff       	call   4f8 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5c3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5cb:	79 db                	jns    5a8 <printint+0x88>
    putc(fd, buf[i]);
}
 5cd:	c9                   	leave  
 5ce:	c3                   	ret    

000005cf <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5cf:	55                   	push   %ebp
 5d0:	89 e5                	mov    %esp,%ebp
 5d2:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5d5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5dc:	8d 45 0c             	lea    0xc(%ebp),%eax
 5df:	83 c0 04             	add    $0x4,%eax
 5e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5e5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5ec:	e9 7d 01 00 00       	jmp    76e <printf+0x19f>
    c = fmt[i] & 0xff;
 5f1:	8b 55 0c             	mov    0xc(%ebp),%edx
 5f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5f7:	01 d0                	add    %edx,%eax
 5f9:	0f b6 00             	movzbl (%eax),%eax
 5fc:	0f be c0             	movsbl %al,%eax
 5ff:	25 ff 00 00 00       	and    $0xff,%eax
 604:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 607:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 60b:	75 2c                	jne    639 <printf+0x6a>
      if(c == '%'){
 60d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 611:	75 0c                	jne    61f <printf+0x50>
        state = '%';
 613:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 61a:	e9 4b 01 00 00       	jmp    76a <printf+0x19b>
      } else {
        putc(fd, c);
 61f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 622:	0f be c0             	movsbl %al,%eax
 625:	89 44 24 04          	mov    %eax,0x4(%esp)
 629:	8b 45 08             	mov    0x8(%ebp),%eax
 62c:	89 04 24             	mov    %eax,(%esp)
 62f:	e8 c4 fe ff ff       	call   4f8 <putc>
 634:	e9 31 01 00 00       	jmp    76a <printf+0x19b>
      }
    } else if(state == '%'){
 639:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 63d:	0f 85 27 01 00 00    	jne    76a <printf+0x19b>
      if(c == 'd'){
 643:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 647:	75 2d                	jne    676 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 649:	8b 45 e8             	mov    -0x18(%ebp),%eax
 64c:	8b 00                	mov    (%eax),%eax
 64e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 655:	00 
 656:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 65d:	00 
 65e:	89 44 24 04          	mov    %eax,0x4(%esp)
 662:	8b 45 08             	mov    0x8(%ebp),%eax
 665:	89 04 24             	mov    %eax,(%esp)
 668:	e8 b3 fe ff ff       	call   520 <printint>
        ap++;
 66d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 671:	e9 ed 00 00 00       	jmp    763 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 676:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 67a:	74 06                	je     682 <printf+0xb3>
 67c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 680:	75 2d                	jne    6af <printf+0xe0>
        printint(fd, *ap, 16, 0);
 682:	8b 45 e8             	mov    -0x18(%ebp),%eax
 685:	8b 00                	mov    (%eax),%eax
 687:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 68e:	00 
 68f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 696:	00 
 697:	89 44 24 04          	mov    %eax,0x4(%esp)
 69b:	8b 45 08             	mov    0x8(%ebp),%eax
 69e:	89 04 24             	mov    %eax,(%esp)
 6a1:	e8 7a fe ff ff       	call   520 <printint>
        ap++;
 6a6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6aa:	e9 b4 00 00 00       	jmp    763 <printf+0x194>
      } else if(c == 's'){
 6af:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6b3:	75 46                	jne    6fb <printf+0x12c>
        s = (char*)*ap;
 6b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6b8:	8b 00                	mov    (%eax),%eax
 6ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6bd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6c5:	75 27                	jne    6ee <printf+0x11f>
          s = "(null)";
 6c7:	c7 45 f4 bf 0a 00 00 	movl   $0xabf,-0xc(%ebp)
        while(*s != 0){
 6ce:	eb 1e                	jmp    6ee <printf+0x11f>
          putc(fd, *s);
 6d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6d3:	0f b6 00             	movzbl (%eax),%eax
 6d6:	0f be c0             	movsbl %al,%eax
 6d9:	89 44 24 04          	mov    %eax,0x4(%esp)
 6dd:	8b 45 08             	mov    0x8(%ebp),%eax
 6e0:	89 04 24             	mov    %eax,(%esp)
 6e3:	e8 10 fe ff ff       	call   4f8 <putc>
          s++;
 6e8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 6ec:	eb 01                	jmp    6ef <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6ee:	90                   	nop
 6ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6f2:	0f b6 00             	movzbl (%eax),%eax
 6f5:	84 c0                	test   %al,%al
 6f7:	75 d7                	jne    6d0 <printf+0x101>
 6f9:	eb 68                	jmp    763 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6fb:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6ff:	75 1d                	jne    71e <printf+0x14f>
        putc(fd, *ap);
 701:	8b 45 e8             	mov    -0x18(%ebp),%eax
 704:	8b 00                	mov    (%eax),%eax
 706:	0f be c0             	movsbl %al,%eax
 709:	89 44 24 04          	mov    %eax,0x4(%esp)
 70d:	8b 45 08             	mov    0x8(%ebp),%eax
 710:	89 04 24             	mov    %eax,(%esp)
 713:	e8 e0 fd ff ff       	call   4f8 <putc>
        ap++;
 718:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 71c:	eb 45                	jmp    763 <printf+0x194>
      } else if(c == '%'){
 71e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 722:	75 17                	jne    73b <printf+0x16c>
        putc(fd, c);
 724:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 727:	0f be c0             	movsbl %al,%eax
 72a:	89 44 24 04          	mov    %eax,0x4(%esp)
 72e:	8b 45 08             	mov    0x8(%ebp),%eax
 731:	89 04 24             	mov    %eax,(%esp)
 734:	e8 bf fd ff ff       	call   4f8 <putc>
 739:	eb 28                	jmp    763 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 73b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 742:	00 
 743:	8b 45 08             	mov    0x8(%ebp),%eax
 746:	89 04 24             	mov    %eax,(%esp)
 749:	e8 aa fd ff ff       	call   4f8 <putc>
        putc(fd, c);
 74e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 751:	0f be c0             	movsbl %al,%eax
 754:	89 44 24 04          	mov    %eax,0x4(%esp)
 758:	8b 45 08             	mov    0x8(%ebp),%eax
 75b:	89 04 24             	mov    %eax,(%esp)
 75e:	e8 95 fd ff ff       	call   4f8 <putc>
      }
      state = 0;
 763:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 76a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 76e:	8b 55 0c             	mov    0xc(%ebp),%edx
 771:	8b 45 f0             	mov    -0x10(%ebp),%eax
 774:	01 d0                	add    %edx,%eax
 776:	0f b6 00             	movzbl (%eax),%eax
 779:	84 c0                	test   %al,%al
 77b:	0f 85 70 fe ff ff    	jne    5f1 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 781:	c9                   	leave  
 782:	c3                   	ret    
 783:	90                   	nop

00000784 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 784:	55                   	push   %ebp
 785:	89 e5                	mov    %esp,%ebp
 787:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 78a:	8b 45 08             	mov    0x8(%ebp),%eax
 78d:	83 e8 08             	sub    $0x8,%eax
 790:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 793:	a1 00 0e 00 00       	mov    0xe00,%eax
 798:	89 45 fc             	mov    %eax,-0x4(%ebp)
 79b:	eb 24                	jmp    7c1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 79d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a0:	8b 00                	mov    (%eax),%eax
 7a2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7a5:	77 12                	ja     7b9 <free+0x35>
 7a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7aa:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7ad:	77 24                	ja     7d3 <free+0x4f>
 7af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b2:	8b 00                	mov    (%eax),%eax
 7b4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7b7:	77 1a                	ja     7d3 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7bc:	8b 00                	mov    (%eax),%eax
 7be:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7c7:	76 d4                	jbe    79d <free+0x19>
 7c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cc:	8b 00                	mov    (%eax),%eax
 7ce:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7d1:	76 ca                	jbe    79d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d6:	8b 40 04             	mov    0x4(%eax),%eax
 7d9:	c1 e0 03             	shl    $0x3,%eax
 7dc:	89 c2                	mov    %eax,%edx
 7de:	03 55 f8             	add    -0x8(%ebp),%edx
 7e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e4:	8b 00                	mov    (%eax),%eax
 7e6:	39 c2                	cmp    %eax,%edx
 7e8:	75 24                	jne    80e <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 7ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ed:	8b 50 04             	mov    0x4(%eax),%edx
 7f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f3:	8b 00                	mov    (%eax),%eax
 7f5:	8b 40 04             	mov    0x4(%eax),%eax
 7f8:	01 c2                	add    %eax,%edx
 7fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fd:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 800:	8b 45 fc             	mov    -0x4(%ebp),%eax
 803:	8b 00                	mov    (%eax),%eax
 805:	8b 10                	mov    (%eax),%edx
 807:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80a:	89 10                	mov    %edx,(%eax)
 80c:	eb 0a                	jmp    818 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 80e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 811:	8b 10                	mov    (%eax),%edx
 813:	8b 45 f8             	mov    -0x8(%ebp),%eax
 816:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 818:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81b:	8b 40 04             	mov    0x4(%eax),%eax
 81e:	c1 e0 03             	shl    $0x3,%eax
 821:	03 45 fc             	add    -0x4(%ebp),%eax
 824:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 827:	75 20                	jne    849 <free+0xc5>
    p->s.size += bp->s.size;
 829:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82c:	8b 50 04             	mov    0x4(%eax),%edx
 82f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 832:	8b 40 04             	mov    0x4(%eax),%eax
 835:	01 c2                	add    %eax,%edx
 837:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 83d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 840:	8b 10                	mov    (%eax),%edx
 842:	8b 45 fc             	mov    -0x4(%ebp),%eax
 845:	89 10                	mov    %edx,(%eax)
 847:	eb 08                	jmp    851 <free+0xcd>
  } else
    p->s.ptr = bp;
 849:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 84f:	89 10                	mov    %edx,(%eax)
  freep = p;
 851:	8b 45 fc             	mov    -0x4(%ebp),%eax
 854:	a3 00 0e 00 00       	mov    %eax,0xe00
}
 859:	c9                   	leave  
 85a:	c3                   	ret    

0000085b <morecore>:

static Header*
morecore(uint nu)
{
 85b:	55                   	push   %ebp
 85c:	89 e5                	mov    %esp,%ebp
 85e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 861:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 868:	77 07                	ja     871 <morecore+0x16>
    nu = 4096;
 86a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 871:	8b 45 08             	mov    0x8(%ebp),%eax
 874:	c1 e0 03             	shl    $0x3,%eax
 877:	89 04 24             	mov    %eax,(%esp)
 87a:	e8 21 fc ff ff       	call   4a0 <sbrk>
 87f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 882:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 886:	75 07                	jne    88f <morecore+0x34>
    return 0;
 888:	b8 00 00 00 00       	mov    $0x0,%eax
 88d:	eb 22                	jmp    8b1 <morecore+0x56>
  hp = (Header*)p;
 88f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 892:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 895:	8b 45 f0             	mov    -0x10(%ebp),%eax
 898:	8b 55 08             	mov    0x8(%ebp),%edx
 89b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 89e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a1:	83 c0 08             	add    $0x8,%eax
 8a4:	89 04 24             	mov    %eax,(%esp)
 8a7:	e8 d8 fe ff ff       	call   784 <free>
  return freep;
 8ac:	a1 00 0e 00 00       	mov    0xe00,%eax
}
 8b1:	c9                   	leave  
 8b2:	c3                   	ret    

000008b3 <malloc>:

void*
malloc(uint nbytes)
{
 8b3:	55                   	push   %ebp
 8b4:	89 e5                	mov    %esp,%ebp
 8b6:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8b9:	8b 45 08             	mov    0x8(%ebp),%eax
 8bc:	83 c0 07             	add    $0x7,%eax
 8bf:	c1 e8 03             	shr    $0x3,%eax
 8c2:	83 c0 01             	add    $0x1,%eax
 8c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8c8:	a1 00 0e 00 00       	mov    0xe00,%eax
 8cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8d4:	75 23                	jne    8f9 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8d6:	c7 45 f0 f8 0d 00 00 	movl   $0xdf8,-0x10(%ebp)
 8dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e0:	a3 00 0e 00 00       	mov    %eax,0xe00
 8e5:	a1 00 0e 00 00       	mov    0xe00,%eax
 8ea:	a3 f8 0d 00 00       	mov    %eax,0xdf8
    base.s.size = 0;
 8ef:	c7 05 fc 0d 00 00 00 	movl   $0x0,0xdfc
 8f6:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8fc:	8b 00                	mov    (%eax),%eax
 8fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 901:	8b 45 f4             	mov    -0xc(%ebp),%eax
 904:	8b 40 04             	mov    0x4(%eax),%eax
 907:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 90a:	72 4d                	jb     959 <malloc+0xa6>
      if(p->s.size == nunits)
 90c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90f:	8b 40 04             	mov    0x4(%eax),%eax
 912:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 915:	75 0c                	jne    923 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 917:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91a:	8b 10                	mov    (%eax),%edx
 91c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91f:	89 10                	mov    %edx,(%eax)
 921:	eb 26                	jmp    949 <malloc+0x96>
      else {
        p->s.size -= nunits;
 923:	8b 45 f4             	mov    -0xc(%ebp),%eax
 926:	8b 40 04             	mov    0x4(%eax),%eax
 929:	89 c2                	mov    %eax,%edx
 92b:	2b 55 ec             	sub    -0x14(%ebp),%edx
 92e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 931:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 934:	8b 45 f4             	mov    -0xc(%ebp),%eax
 937:	8b 40 04             	mov    0x4(%eax),%eax
 93a:	c1 e0 03             	shl    $0x3,%eax
 93d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 940:	8b 45 f4             	mov    -0xc(%ebp),%eax
 943:	8b 55 ec             	mov    -0x14(%ebp),%edx
 946:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 949:	8b 45 f0             	mov    -0x10(%ebp),%eax
 94c:	a3 00 0e 00 00       	mov    %eax,0xe00
      return (void*)(p + 1);
 951:	8b 45 f4             	mov    -0xc(%ebp),%eax
 954:	83 c0 08             	add    $0x8,%eax
 957:	eb 38                	jmp    991 <malloc+0xde>
    }
    if(p == freep)
 959:	a1 00 0e 00 00       	mov    0xe00,%eax
 95e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 961:	75 1b                	jne    97e <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 963:	8b 45 ec             	mov    -0x14(%ebp),%eax
 966:	89 04 24             	mov    %eax,(%esp)
 969:	e8 ed fe ff ff       	call   85b <morecore>
 96e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 971:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 975:	75 07                	jne    97e <malloc+0xcb>
        return 0;
 977:	b8 00 00 00 00       	mov    $0x0,%eax
 97c:	eb 13                	jmp    991 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 97e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 981:	89 45 f0             	mov    %eax,-0x10(%ebp)
 984:	8b 45 f4             	mov    -0xc(%ebp),%eax
 987:	8b 00                	mov    (%eax),%eax
 989:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 98c:	e9 70 ff ff ff       	jmp    901 <malloc+0x4e>
}
 991:	c9                   	leave  
 992:	c3                   	ret    
 993:	90                   	nop

00000994 <pthread_create>:
	clone's 3rd argument, *stek, should be allocated here?
*/

#define PAGESIZE (4096)  //Maybe 4092??

int pthread_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine) (void*), void *arg){
 994:	55                   	push   %ebp
 995:	89 e5                	mov    %esp,%ebp
 997:	83 ec 28             	sub    $0x28,%esp

	void *mystek = malloc((uint)PAGESIZE*2); //Why do we need the *2?
 99a:	c7 04 24 00 20 00 00 	movl   $0x2000,(%esp)
 9a1:	e8 0d ff ff ff       	call   8b3 <malloc>
 9a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
//zzddhhtjzz/xv6/blob/master
	if((uint)mystek % PAGESIZE){
 9a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ac:	25 ff 0f 00 00       	and    $0xfff,%eax
 9b1:	85 c0                	test   %eax,%eax
 9b3:	74 15                	je     9ca <pthread_create+0x36>
		mystek += 4096 - ((uint)mystek % PAGESIZE);
 9b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b8:	89 c2                	mov    %eax,%edx
 9ba:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
 9c0:	b8 00 10 00 00       	mov    $0x1000,%eax
 9c5:	29 d0                	sub    %edx,%eax
 9c7:	01 45 f4             	add    %eax,-0xc(%ebp)
	}
	thread->pid = clone(start_routine, arg, mystek);
 9ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9cd:	89 44 24 08          	mov    %eax,0x8(%esp)
 9d1:	8b 45 14             	mov    0x14(%ebp),%eax
 9d4:	89 44 24 04          	mov    %eax,0x4(%esp)
 9d8:	8b 45 10             	mov    0x10(%ebp),%eax
 9db:	89 04 24             	mov    %eax,(%esp)
 9de:	e8 dd fa ff ff       	call   4c0 <clone>
 9e3:	8b 55 08             	mov    0x8(%ebp),%edx
 9e6:	89 02                	mov    %eax,(%edx)
	return thread->pid;
 9e8:	8b 45 08             	mov    0x8(%ebp),%eax
 9eb:	8b 00                	mov    (%eax),%eax
}
 9ed:	c9                   	leave  
 9ee:	c3                   	ret    

000009ef <pthread_join>:

int pthread_join(pthread_t thread, void **retval){
 9ef:	55                   	push   %ebp
 9f0:	89 e5                	mov    %esp,%ebp
 9f2:	83 ec 28             	sub    $0x28,%esp

	void *stek;

	join((int)thread.pid, &stek, (void*)retval);
 9f5:	8b 45 08             	mov    0x8(%ebp),%eax
 9f8:	8b 55 0c             	mov    0xc(%ebp),%edx
 9fb:	89 54 24 08          	mov    %edx,0x8(%esp)
 9ff:	8d 55 f4             	lea    -0xc(%ebp),%edx
 a02:	89 54 24 04          	mov    %edx,0x4(%esp)
 a06:	89 04 24             	mov    %eax,(%esp)
 a09:	e8 ba fa ff ff       	call   4c8 <join>

	free(stek);
 a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a11:	89 04 24             	mov    %eax,(%esp)
 a14:	e8 6b fd ff ff       	call   784 <free>

	return 0;
 a19:	b8 00 00 00 00       	mov    $0x0,%eax
}
 a1e:	c9                   	leave  
 a1f:	c3                   	ret    

00000a20 <pthread_exit>:

int pthread_exit(void *retval){
 a20:	55                   	push   %ebp
 a21:	89 e5                	mov    %esp,%ebp
 a23:	83 ec 18             	sub    $0x18,%esp

	texit(retval);
 a26:	8b 45 08             	mov    0x8(%ebp),%eax
 a29:	89 04 24             	mov    %eax,(%esp)
 a2c:	e8 9f fa ff ff       	call   4d0 <texit>

	return 0;
 a31:	b8 00 00 00 00       	mov    $0x0,%eax
}
 a36:	c9                   	leave  
 a37:	c3                   	ret    

00000a38 <pthread_mutex_init>:


int pthread_mutex_init(pthread_mutex_t *mutex, const pthread_mutex_attr_t *attr){
 a38:	55                   	push   %ebp
 a39:	89 e5                	mov    %esp,%ebp
 a3b:	83 ec 18             	sub    $0x18,%esp

	int mid = mutex_init();
 a3e:	e8 95 fa ff ff       	call   4d8 <mutex_init>
 a43:	89 45 f4             	mov    %eax,-0xc(%ebp)

	//returns the id of the initalized mutex
	return mid;
 a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
 a49:	c9                   	leave  
 a4a:	c3                   	ret    

00000a4b <pthread_mutex_destroy>:


int pthread_mutex_destroy(pthread_mutex_t *mutex){
 a4b:	55                   	push   %ebp
 a4c:	89 e5                	mov    %esp,%ebp
 a4e:	83 ec 18             	sub    $0x18,%esp

	//flag this mutex as destroyed
	mutex_destroy(mutex->mid);
 a51:	8b 45 08             	mov    0x8(%ebp),%eax
 a54:	8b 40 04             	mov    0x4(%eax),%eax
 a57:	89 04 24             	mov    %eax,(%esp)
 a5a:	e8 81 fa ff ff       	call   4e0 <mutex_destroy>
	return 0;
 a5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 a64:	c9                   	leave  
 a65:	c3                   	ret    

00000a66 <pthread_mutex_lock>:


int pthread_mutex_lock(pthread_mutex_t *mutex){
 a66:	55                   	push   %ebp
 a67:	89 e5                	mov    %esp,%ebp
 a69:	83 ec 18             	sub    $0x18,%esp

	mutex_lock(mutex->mid);
 a6c:	8b 45 08             	mov    0x8(%ebp),%eax
 a6f:	8b 40 04             	mov    0x4(%eax),%eax
 a72:	89 04 24             	mov    %eax,(%esp)
 a75:	e8 6e fa ff ff       	call   4e8 <mutex_lock>
	return 0;
 a7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 a7f:	c9                   	leave  
 a80:	c3                   	ret    

00000a81 <pthread_mutex_unlock>:


int pthread_mutex_unlock(pthread_mutex_t *mutex){
 a81:	55                   	push   %ebp
 a82:	89 e5                	mov    %esp,%ebp
 a84:	83 ec 18             	sub    $0x18,%esp

	mutex_unlock(mutex->mid);
 a87:	8b 45 08             	mov    0x8(%ebp),%eax
 a8a:	8b 40 04             	mov    0x4(%eax),%eax
 a8d:	89 04 24             	mov    %eax,(%esp)
 a90:	e8 5b fa ff ff       	call   4f0 <mutex_unlock>
	return 0;
 a95:	b8 00 00 00 00       	mov    $0x0,%eax
 a9a:	c9                   	leave  
 a9b:	c3                   	ret    
