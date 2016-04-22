
_zombie:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
  if(fork() > 0)
   9:	e8 72 02 00 00       	call   280 <fork>
   e:	85 c0                	test   %eax,%eax
  10:	7e 0c                	jle    1e <main+0x1e>
    sleep(5);  // Let child exit before parent.
  12:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  19:	e8 fa 02 00 00       	call   318 <sleep>
  exit();
  1e:	e8 65 02 00 00       	call   288 <exit>
  23:	90                   	nop

00000024 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  24:	55                   	push   %ebp
  25:	89 e5                	mov    %esp,%ebp
  27:	57                   	push   %edi
  28:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  2c:	8b 55 10             	mov    0x10(%ebp),%edx
  2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  32:	89 cb                	mov    %ecx,%ebx
  34:	89 df                	mov    %ebx,%edi
  36:	89 d1                	mov    %edx,%ecx
  38:	fc                   	cld    
  39:	f3 aa                	rep stos %al,%es:(%edi)
  3b:	89 ca                	mov    %ecx,%edx
  3d:	89 fb                	mov    %edi,%ebx
  3f:	89 5d 08             	mov    %ebx,0x8(%ebp)
  42:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  45:	5b                   	pop    %ebx
  46:	5f                   	pop    %edi
  47:	5d                   	pop    %ebp
  48:	c3                   	ret    

00000049 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  49:	55                   	push   %ebp
  4a:	89 e5                	mov    %esp,%ebp
  4c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  4f:	8b 45 08             	mov    0x8(%ebp),%eax
  52:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  55:	90                   	nop
  56:	8b 45 0c             	mov    0xc(%ebp),%eax
  59:	0f b6 10             	movzbl (%eax),%edx
  5c:	8b 45 08             	mov    0x8(%ebp),%eax
  5f:	88 10                	mov    %dl,(%eax)
  61:	8b 45 08             	mov    0x8(%ebp),%eax
  64:	0f b6 00             	movzbl (%eax),%eax
  67:	84 c0                	test   %al,%al
  69:	0f 95 c0             	setne  %al
  6c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  70:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  74:	84 c0                	test   %al,%al
  76:	75 de                	jne    56 <strcpy+0xd>
    ;
  return os;
  78:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  7b:	c9                   	leave  
  7c:	c3                   	ret    

0000007d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  7d:	55                   	push   %ebp
  7e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  80:	eb 08                	jmp    8a <strcmp+0xd>
    p++, q++;
  82:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  86:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  8a:	8b 45 08             	mov    0x8(%ebp),%eax
  8d:	0f b6 00             	movzbl (%eax),%eax
  90:	84 c0                	test   %al,%al
  92:	74 10                	je     a4 <strcmp+0x27>
  94:	8b 45 08             	mov    0x8(%ebp),%eax
  97:	0f b6 10             	movzbl (%eax),%edx
  9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  9d:	0f b6 00             	movzbl (%eax),%eax
  a0:	38 c2                	cmp    %al,%dl
  a2:	74 de                	je     82 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  a4:	8b 45 08             	mov    0x8(%ebp),%eax
  a7:	0f b6 00             	movzbl (%eax),%eax
  aa:	0f b6 d0             	movzbl %al,%edx
  ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  b0:	0f b6 00             	movzbl (%eax),%eax
  b3:	0f b6 c0             	movzbl %al,%eax
  b6:	89 d1                	mov    %edx,%ecx
  b8:	29 c1                	sub    %eax,%ecx
  ba:	89 c8                	mov    %ecx,%eax
}
  bc:	5d                   	pop    %ebp
  bd:	c3                   	ret    

000000be <strlen>:

uint
strlen(char *s)
{
  be:	55                   	push   %ebp
  bf:	89 e5                	mov    %esp,%ebp
  c1:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  c4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  cb:	eb 04                	jmp    d1 <strlen+0x13>
  cd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  d4:	03 45 08             	add    0x8(%ebp),%eax
  d7:	0f b6 00             	movzbl (%eax),%eax
  da:	84 c0                	test   %al,%al
  dc:	75 ef                	jne    cd <strlen+0xf>
    ;
  return n;
  de:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  e1:	c9                   	leave  
  e2:	c3                   	ret    

000000e3 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e3:	55                   	push   %ebp
  e4:	89 e5                	mov    %esp,%ebp
  e6:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
  e9:	8b 45 10             	mov    0x10(%ebp),%eax
  ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  f7:	8b 45 08             	mov    0x8(%ebp),%eax
  fa:	89 04 24             	mov    %eax,(%esp)
  fd:	e8 22 ff ff ff       	call   24 <stosb>
  return dst;
 102:	8b 45 08             	mov    0x8(%ebp),%eax
}
 105:	c9                   	leave  
 106:	c3                   	ret    

00000107 <strchr>:

char*
strchr(const char *s, char c)
{
 107:	55                   	push   %ebp
 108:	89 e5                	mov    %esp,%ebp
 10a:	83 ec 04             	sub    $0x4,%esp
 10d:	8b 45 0c             	mov    0xc(%ebp),%eax
 110:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 113:	eb 14                	jmp    129 <strchr+0x22>
    if(*s == c)
 115:	8b 45 08             	mov    0x8(%ebp),%eax
 118:	0f b6 00             	movzbl (%eax),%eax
 11b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 11e:	75 05                	jne    125 <strchr+0x1e>
      return (char*)s;
 120:	8b 45 08             	mov    0x8(%ebp),%eax
 123:	eb 13                	jmp    138 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 125:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 129:	8b 45 08             	mov    0x8(%ebp),%eax
 12c:	0f b6 00             	movzbl (%eax),%eax
 12f:	84 c0                	test   %al,%al
 131:	75 e2                	jne    115 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 133:	b8 00 00 00 00       	mov    $0x0,%eax
}
 138:	c9                   	leave  
 139:	c3                   	ret    

0000013a <gets>:

char*
gets(char *buf, int max)
{
 13a:	55                   	push   %ebp
 13b:	89 e5                	mov    %esp,%ebp
 13d:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 140:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 147:	eb 44                	jmp    18d <gets+0x53>
    cc = read(0, &c, 1);
 149:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 150:	00 
 151:	8d 45 ef             	lea    -0x11(%ebp),%eax
 154:	89 44 24 04          	mov    %eax,0x4(%esp)
 158:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 15f:	e8 3c 01 00 00       	call   2a0 <read>
 164:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 167:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 16b:	7e 2d                	jle    19a <gets+0x60>
      break;
    buf[i++] = c;
 16d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 170:	03 45 08             	add    0x8(%ebp),%eax
 173:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 177:	88 10                	mov    %dl,(%eax)
 179:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 17d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 181:	3c 0a                	cmp    $0xa,%al
 183:	74 16                	je     19b <gets+0x61>
 185:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 189:	3c 0d                	cmp    $0xd,%al
 18b:	74 0e                	je     19b <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 18d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 190:	83 c0 01             	add    $0x1,%eax
 193:	3b 45 0c             	cmp    0xc(%ebp),%eax
 196:	7c b1                	jl     149 <gets+0xf>
 198:	eb 01                	jmp    19b <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 19a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 19b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19e:	03 45 08             	add    0x8(%ebp),%eax
 1a1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1a4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1a7:	c9                   	leave  
 1a8:	c3                   	ret    

000001a9 <stat>:

int
stat(char *n, struct stat *st)
{
 1a9:	55                   	push   %ebp
 1aa:	89 e5                	mov    %esp,%ebp
 1ac:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1b6:	00 
 1b7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ba:	89 04 24             	mov    %eax,(%esp)
 1bd:	e8 06 01 00 00       	call   2c8 <open>
 1c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1c9:	79 07                	jns    1d2 <stat+0x29>
    return -1;
 1cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1d0:	eb 23                	jmp    1f5 <stat+0x4c>
  r = fstat(fd, st);
 1d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d5:	89 44 24 04          	mov    %eax,0x4(%esp)
 1d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1dc:	89 04 24             	mov    %eax,(%esp)
 1df:	e8 fc 00 00 00       	call   2e0 <fstat>
 1e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ea:	89 04 24             	mov    %eax,(%esp)
 1ed:	e8 be 00 00 00       	call   2b0 <close>
  return r;
 1f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1f5:	c9                   	leave  
 1f6:	c3                   	ret    

000001f7 <atoi>:

int
atoi(const char *s)
{
 1f7:	55                   	push   %ebp
 1f8:	89 e5                	mov    %esp,%ebp
 1fa:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 1fd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 204:	eb 23                	jmp    229 <atoi+0x32>
    n = n*10 + *s++ - '0';
 206:	8b 55 fc             	mov    -0x4(%ebp),%edx
 209:	89 d0                	mov    %edx,%eax
 20b:	c1 e0 02             	shl    $0x2,%eax
 20e:	01 d0                	add    %edx,%eax
 210:	01 c0                	add    %eax,%eax
 212:	89 c2                	mov    %eax,%edx
 214:	8b 45 08             	mov    0x8(%ebp),%eax
 217:	0f b6 00             	movzbl (%eax),%eax
 21a:	0f be c0             	movsbl %al,%eax
 21d:	01 d0                	add    %edx,%eax
 21f:	83 e8 30             	sub    $0x30,%eax
 222:	89 45 fc             	mov    %eax,-0x4(%ebp)
 225:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 229:	8b 45 08             	mov    0x8(%ebp),%eax
 22c:	0f b6 00             	movzbl (%eax),%eax
 22f:	3c 2f                	cmp    $0x2f,%al
 231:	7e 0a                	jle    23d <atoi+0x46>
 233:	8b 45 08             	mov    0x8(%ebp),%eax
 236:	0f b6 00             	movzbl (%eax),%eax
 239:	3c 39                	cmp    $0x39,%al
 23b:	7e c9                	jle    206 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 23d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 240:	c9                   	leave  
 241:	c3                   	ret    

00000242 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 242:	55                   	push   %ebp
 243:	89 e5                	mov    %esp,%ebp
 245:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 248:	8b 45 08             	mov    0x8(%ebp),%eax
 24b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 24e:	8b 45 0c             	mov    0xc(%ebp),%eax
 251:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 254:	eb 13                	jmp    269 <memmove+0x27>
    *dst++ = *src++;
 256:	8b 45 f8             	mov    -0x8(%ebp),%eax
 259:	0f b6 10             	movzbl (%eax),%edx
 25c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 25f:	88 10                	mov    %dl,(%eax)
 261:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 265:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 269:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 26d:	0f 9f c0             	setg   %al
 270:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 274:	84 c0                	test   %al,%al
 276:	75 de                	jne    256 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 278:	8b 45 08             	mov    0x8(%ebp),%eax
}
 27b:	c9                   	leave  
 27c:	c3                   	ret    
 27d:	90                   	nop
 27e:	90                   	nop
 27f:	90                   	nop

00000280 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 280:	b8 01 00 00 00       	mov    $0x1,%eax
 285:	cd 40                	int    $0x40
 287:	c3                   	ret    

00000288 <exit>:
SYSCALL(exit)
 288:	b8 02 00 00 00       	mov    $0x2,%eax
 28d:	cd 40                	int    $0x40
 28f:	c3                   	ret    

00000290 <wait>:
SYSCALL(wait)
 290:	b8 03 00 00 00       	mov    $0x3,%eax
 295:	cd 40                	int    $0x40
 297:	c3                   	ret    

00000298 <pipe>:
SYSCALL(pipe)
 298:	b8 04 00 00 00       	mov    $0x4,%eax
 29d:	cd 40                	int    $0x40
 29f:	c3                   	ret    

000002a0 <read>:
SYSCALL(read)
 2a0:	b8 05 00 00 00       	mov    $0x5,%eax
 2a5:	cd 40                	int    $0x40
 2a7:	c3                   	ret    

000002a8 <write>:
SYSCALL(write)
 2a8:	b8 10 00 00 00       	mov    $0x10,%eax
 2ad:	cd 40                	int    $0x40
 2af:	c3                   	ret    

000002b0 <close>:
SYSCALL(close)
 2b0:	b8 15 00 00 00       	mov    $0x15,%eax
 2b5:	cd 40                	int    $0x40
 2b7:	c3                   	ret    

000002b8 <kill>:
SYSCALL(kill)
 2b8:	b8 06 00 00 00       	mov    $0x6,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <exec>:
SYSCALL(exec)
 2c0:	b8 07 00 00 00       	mov    $0x7,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <open>:
SYSCALL(open)
 2c8:	b8 0f 00 00 00       	mov    $0xf,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <mknod>:
SYSCALL(mknod)
 2d0:	b8 11 00 00 00       	mov    $0x11,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <unlink>:
SYSCALL(unlink)
 2d8:	b8 12 00 00 00       	mov    $0x12,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <fstat>:
SYSCALL(fstat)
 2e0:	b8 08 00 00 00       	mov    $0x8,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <link>:
SYSCALL(link)
 2e8:	b8 13 00 00 00       	mov    $0x13,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <mkdir>:
SYSCALL(mkdir)
 2f0:	b8 14 00 00 00       	mov    $0x14,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <chdir>:
SYSCALL(chdir)
 2f8:	b8 09 00 00 00       	mov    $0x9,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <dup>:
SYSCALL(dup)
 300:	b8 0a 00 00 00       	mov    $0xa,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <getpid>:
SYSCALL(getpid)
 308:	b8 0b 00 00 00       	mov    $0xb,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <sbrk>:
SYSCALL(sbrk)
 310:	b8 0c 00 00 00       	mov    $0xc,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <sleep>:
SYSCALL(sleep)
 318:	b8 0d 00 00 00       	mov    $0xd,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <uptime>:
SYSCALL(uptime)
 320:	b8 0e 00 00 00       	mov    $0xe,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <halt>:
SYSCALL(halt)
 328:	b8 16 00 00 00       	mov    $0x16,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <clone>:

SYSCALL(clone)
 330:	b8 19 00 00 00       	mov    $0x19,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <join>:
SYSCALL(join)
 338:	b8 1a 00 00 00       	mov    $0x1a,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <texit>:
SYSCALL(texit)
 340:	b8 1b 00 00 00       	mov    $0x1b,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <mutex_init>:
SYSCALL(mutex_init)
 348:	b8 1c 00 00 00       	mov    $0x1c,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <mutex_destroy>:
SYSCALL(mutex_destroy)
 350:	b8 1d 00 00 00       	mov    $0x1d,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <mutex_lock>:
SYSCALL(mutex_lock)
 358:	b8 1e 00 00 00       	mov    $0x1e,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <mutex_unlock>:
 360:	b8 1f 00 00 00       	mov    $0x1f,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 368:	55                   	push   %ebp
 369:	89 e5                	mov    %esp,%ebp
 36b:	83 ec 28             	sub    $0x28,%esp
 36e:	8b 45 0c             	mov    0xc(%ebp),%eax
 371:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 374:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 37b:	00 
 37c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 37f:	89 44 24 04          	mov    %eax,0x4(%esp)
 383:	8b 45 08             	mov    0x8(%ebp),%eax
 386:	89 04 24             	mov    %eax,(%esp)
 389:	e8 1a ff ff ff       	call   2a8 <write>
}
 38e:	c9                   	leave  
 38f:	c3                   	ret    

00000390 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 390:	55                   	push   %ebp
 391:	89 e5                	mov    %esp,%ebp
 393:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 396:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 39d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3a1:	74 17                	je     3ba <printint+0x2a>
 3a3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3a7:	79 11                	jns    3ba <printint+0x2a>
    neg = 1;
 3a9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3b0:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b3:	f7 d8                	neg    %eax
 3b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3b8:	eb 06                	jmp    3c0 <printint+0x30>
  } else {
    x = xx;
 3ba:	8b 45 0c             	mov    0xc(%ebp),%eax
 3bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3cd:	ba 00 00 00 00       	mov    $0x0,%edx
 3d2:	f7 f1                	div    %ecx
 3d4:	89 d0                	mov    %edx,%eax
 3d6:	0f b6 90 30 0c 00 00 	movzbl 0xc30(%eax),%edx
 3dd:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3e0:	03 45 f4             	add    -0xc(%ebp),%eax
 3e3:	88 10                	mov    %dl,(%eax)
 3e5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 3e9:	8b 55 10             	mov    0x10(%ebp),%edx
 3ec:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 3ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3f2:	ba 00 00 00 00       	mov    $0x0,%edx
 3f7:	f7 75 d4             	divl   -0x2c(%ebp)
 3fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3fd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 401:	75 c4                	jne    3c7 <printint+0x37>
  if(neg)
 403:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 407:	74 2a                	je     433 <printint+0xa3>
    buf[i++] = '-';
 409:	8d 45 dc             	lea    -0x24(%ebp),%eax
 40c:	03 45 f4             	add    -0xc(%ebp),%eax
 40f:	c6 00 2d             	movb   $0x2d,(%eax)
 412:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 416:	eb 1b                	jmp    433 <printint+0xa3>
    putc(fd, buf[i]);
 418:	8d 45 dc             	lea    -0x24(%ebp),%eax
 41b:	03 45 f4             	add    -0xc(%ebp),%eax
 41e:	0f b6 00             	movzbl (%eax),%eax
 421:	0f be c0             	movsbl %al,%eax
 424:	89 44 24 04          	mov    %eax,0x4(%esp)
 428:	8b 45 08             	mov    0x8(%ebp),%eax
 42b:	89 04 24             	mov    %eax,(%esp)
 42e:	e8 35 ff ff ff       	call   368 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 433:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 437:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 43b:	79 db                	jns    418 <printint+0x88>
    putc(fd, buf[i]);
}
 43d:	c9                   	leave  
 43e:	c3                   	ret    

0000043f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 43f:	55                   	push   %ebp
 440:	89 e5                	mov    %esp,%ebp
 442:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 445:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 44c:	8d 45 0c             	lea    0xc(%ebp),%eax
 44f:	83 c0 04             	add    $0x4,%eax
 452:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 455:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 45c:	e9 7d 01 00 00       	jmp    5de <printf+0x19f>
    c = fmt[i] & 0xff;
 461:	8b 55 0c             	mov    0xc(%ebp),%edx
 464:	8b 45 f0             	mov    -0x10(%ebp),%eax
 467:	01 d0                	add    %edx,%eax
 469:	0f b6 00             	movzbl (%eax),%eax
 46c:	0f be c0             	movsbl %al,%eax
 46f:	25 ff 00 00 00       	and    $0xff,%eax
 474:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 477:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 47b:	75 2c                	jne    4a9 <printf+0x6a>
      if(c == '%'){
 47d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 481:	75 0c                	jne    48f <printf+0x50>
        state = '%';
 483:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 48a:	e9 4b 01 00 00       	jmp    5da <printf+0x19b>
      } else {
        putc(fd, c);
 48f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 492:	0f be c0             	movsbl %al,%eax
 495:	89 44 24 04          	mov    %eax,0x4(%esp)
 499:	8b 45 08             	mov    0x8(%ebp),%eax
 49c:	89 04 24             	mov    %eax,(%esp)
 49f:	e8 c4 fe ff ff       	call   368 <putc>
 4a4:	e9 31 01 00 00       	jmp    5da <printf+0x19b>
      }
    } else if(state == '%'){
 4a9:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4ad:	0f 85 27 01 00 00    	jne    5da <printf+0x19b>
      if(c == 'd'){
 4b3:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4b7:	75 2d                	jne    4e6 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 4b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4bc:	8b 00                	mov    (%eax),%eax
 4be:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 4c5:	00 
 4c6:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 4cd:	00 
 4ce:	89 44 24 04          	mov    %eax,0x4(%esp)
 4d2:	8b 45 08             	mov    0x8(%ebp),%eax
 4d5:	89 04 24             	mov    %eax,(%esp)
 4d8:	e8 b3 fe ff ff       	call   390 <printint>
        ap++;
 4dd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4e1:	e9 ed 00 00 00       	jmp    5d3 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 4e6:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4ea:	74 06                	je     4f2 <printf+0xb3>
 4ec:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4f0:	75 2d                	jne    51f <printf+0xe0>
        printint(fd, *ap, 16, 0);
 4f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4f5:	8b 00                	mov    (%eax),%eax
 4f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 4fe:	00 
 4ff:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 506:	00 
 507:	89 44 24 04          	mov    %eax,0x4(%esp)
 50b:	8b 45 08             	mov    0x8(%ebp),%eax
 50e:	89 04 24             	mov    %eax,(%esp)
 511:	e8 7a fe ff ff       	call   390 <printint>
        ap++;
 516:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 51a:	e9 b4 00 00 00       	jmp    5d3 <printf+0x194>
      } else if(c == 's'){
 51f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 523:	75 46                	jne    56b <printf+0x12c>
        s = (char*)*ap;
 525:	8b 45 e8             	mov    -0x18(%ebp),%eax
 528:	8b 00                	mov    (%eax),%eax
 52a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 52d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 531:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 535:	75 27                	jne    55e <printf+0x11f>
          s = "(null)";
 537:	c7 45 f4 0c 09 00 00 	movl   $0x90c,-0xc(%ebp)
        while(*s != 0){
 53e:	eb 1e                	jmp    55e <printf+0x11f>
          putc(fd, *s);
 540:	8b 45 f4             	mov    -0xc(%ebp),%eax
 543:	0f b6 00             	movzbl (%eax),%eax
 546:	0f be c0             	movsbl %al,%eax
 549:	89 44 24 04          	mov    %eax,0x4(%esp)
 54d:	8b 45 08             	mov    0x8(%ebp),%eax
 550:	89 04 24             	mov    %eax,(%esp)
 553:	e8 10 fe ff ff       	call   368 <putc>
          s++;
 558:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 55c:	eb 01                	jmp    55f <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 55e:	90                   	nop
 55f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 562:	0f b6 00             	movzbl (%eax),%eax
 565:	84 c0                	test   %al,%al
 567:	75 d7                	jne    540 <printf+0x101>
 569:	eb 68                	jmp    5d3 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 56b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 56f:	75 1d                	jne    58e <printf+0x14f>
        putc(fd, *ap);
 571:	8b 45 e8             	mov    -0x18(%ebp),%eax
 574:	8b 00                	mov    (%eax),%eax
 576:	0f be c0             	movsbl %al,%eax
 579:	89 44 24 04          	mov    %eax,0x4(%esp)
 57d:	8b 45 08             	mov    0x8(%ebp),%eax
 580:	89 04 24             	mov    %eax,(%esp)
 583:	e8 e0 fd ff ff       	call   368 <putc>
        ap++;
 588:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 58c:	eb 45                	jmp    5d3 <printf+0x194>
      } else if(c == '%'){
 58e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 592:	75 17                	jne    5ab <printf+0x16c>
        putc(fd, c);
 594:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 597:	0f be c0             	movsbl %al,%eax
 59a:	89 44 24 04          	mov    %eax,0x4(%esp)
 59e:	8b 45 08             	mov    0x8(%ebp),%eax
 5a1:	89 04 24             	mov    %eax,(%esp)
 5a4:	e8 bf fd ff ff       	call   368 <putc>
 5a9:	eb 28                	jmp    5d3 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5ab:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 5b2:	00 
 5b3:	8b 45 08             	mov    0x8(%ebp),%eax
 5b6:	89 04 24             	mov    %eax,(%esp)
 5b9:	e8 aa fd ff ff       	call   368 <putc>
        putc(fd, c);
 5be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5c1:	0f be c0             	movsbl %al,%eax
 5c4:	89 44 24 04          	mov    %eax,0x4(%esp)
 5c8:	8b 45 08             	mov    0x8(%ebp),%eax
 5cb:	89 04 24             	mov    %eax,(%esp)
 5ce:	e8 95 fd ff ff       	call   368 <putc>
      }
      state = 0;
 5d3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5da:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5de:	8b 55 0c             	mov    0xc(%ebp),%edx
 5e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5e4:	01 d0                	add    %edx,%eax
 5e6:	0f b6 00             	movzbl (%eax),%eax
 5e9:	84 c0                	test   %al,%al
 5eb:	0f 85 70 fe ff ff    	jne    461 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5f1:	c9                   	leave  
 5f2:	c3                   	ret    
 5f3:	90                   	nop

000005f4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5f4:	55                   	push   %ebp
 5f5:	89 e5                	mov    %esp,%ebp
 5f7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5fa:	8b 45 08             	mov    0x8(%ebp),%eax
 5fd:	83 e8 08             	sub    $0x8,%eax
 600:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 603:	a1 4c 0c 00 00       	mov    0xc4c,%eax
 608:	89 45 fc             	mov    %eax,-0x4(%ebp)
 60b:	eb 24                	jmp    631 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 60d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 610:	8b 00                	mov    (%eax),%eax
 612:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 615:	77 12                	ja     629 <free+0x35>
 617:	8b 45 f8             	mov    -0x8(%ebp),%eax
 61a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 61d:	77 24                	ja     643 <free+0x4f>
 61f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 622:	8b 00                	mov    (%eax),%eax
 624:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 627:	77 1a                	ja     643 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 629:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62c:	8b 00                	mov    (%eax),%eax
 62e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 631:	8b 45 f8             	mov    -0x8(%ebp),%eax
 634:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 637:	76 d4                	jbe    60d <free+0x19>
 639:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63c:	8b 00                	mov    (%eax),%eax
 63e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 641:	76 ca                	jbe    60d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 643:	8b 45 f8             	mov    -0x8(%ebp),%eax
 646:	8b 40 04             	mov    0x4(%eax),%eax
 649:	c1 e0 03             	shl    $0x3,%eax
 64c:	89 c2                	mov    %eax,%edx
 64e:	03 55 f8             	add    -0x8(%ebp),%edx
 651:	8b 45 fc             	mov    -0x4(%ebp),%eax
 654:	8b 00                	mov    (%eax),%eax
 656:	39 c2                	cmp    %eax,%edx
 658:	75 24                	jne    67e <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 65a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65d:	8b 50 04             	mov    0x4(%eax),%edx
 660:	8b 45 fc             	mov    -0x4(%ebp),%eax
 663:	8b 00                	mov    (%eax),%eax
 665:	8b 40 04             	mov    0x4(%eax),%eax
 668:	01 c2                	add    %eax,%edx
 66a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 670:	8b 45 fc             	mov    -0x4(%ebp),%eax
 673:	8b 00                	mov    (%eax),%eax
 675:	8b 10                	mov    (%eax),%edx
 677:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67a:	89 10                	mov    %edx,(%eax)
 67c:	eb 0a                	jmp    688 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 67e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 681:	8b 10                	mov    (%eax),%edx
 683:	8b 45 f8             	mov    -0x8(%ebp),%eax
 686:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 688:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68b:	8b 40 04             	mov    0x4(%eax),%eax
 68e:	c1 e0 03             	shl    $0x3,%eax
 691:	03 45 fc             	add    -0x4(%ebp),%eax
 694:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 697:	75 20                	jne    6b9 <free+0xc5>
    p->s.size += bp->s.size;
 699:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69c:	8b 50 04             	mov    0x4(%eax),%edx
 69f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a2:	8b 40 04             	mov    0x4(%eax),%eax
 6a5:	01 c2                	add    %eax,%edx
 6a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6aa:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b0:	8b 10                	mov    (%eax),%edx
 6b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b5:	89 10                	mov    %edx,(%eax)
 6b7:	eb 08                	jmp    6c1 <free+0xcd>
  } else
    p->s.ptr = bp;
 6b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bc:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6bf:	89 10                	mov    %edx,(%eax)
  freep = p;
 6c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c4:	a3 4c 0c 00 00       	mov    %eax,0xc4c
}
 6c9:	c9                   	leave  
 6ca:	c3                   	ret    

000006cb <morecore>:

static Header*
morecore(uint nu)
{
 6cb:	55                   	push   %ebp
 6cc:	89 e5                	mov    %esp,%ebp
 6ce:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6d1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6d8:	77 07                	ja     6e1 <morecore+0x16>
    nu = 4096;
 6da:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6e1:	8b 45 08             	mov    0x8(%ebp),%eax
 6e4:	c1 e0 03             	shl    $0x3,%eax
 6e7:	89 04 24             	mov    %eax,(%esp)
 6ea:	e8 21 fc ff ff       	call   310 <sbrk>
 6ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6f2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6f6:	75 07                	jne    6ff <morecore+0x34>
    return 0;
 6f8:	b8 00 00 00 00       	mov    $0x0,%eax
 6fd:	eb 22                	jmp    721 <morecore+0x56>
  hp = (Header*)p;
 6ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 702:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 705:	8b 45 f0             	mov    -0x10(%ebp),%eax
 708:	8b 55 08             	mov    0x8(%ebp),%edx
 70b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 70e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 711:	83 c0 08             	add    $0x8,%eax
 714:	89 04 24             	mov    %eax,(%esp)
 717:	e8 d8 fe ff ff       	call   5f4 <free>
  return freep;
 71c:	a1 4c 0c 00 00       	mov    0xc4c,%eax
}
 721:	c9                   	leave  
 722:	c3                   	ret    

00000723 <malloc>:

void*
malloc(uint nbytes)
{
 723:	55                   	push   %ebp
 724:	89 e5                	mov    %esp,%ebp
 726:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 729:	8b 45 08             	mov    0x8(%ebp),%eax
 72c:	83 c0 07             	add    $0x7,%eax
 72f:	c1 e8 03             	shr    $0x3,%eax
 732:	83 c0 01             	add    $0x1,%eax
 735:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 738:	a1 4c 0c 00 00       	mov    0xc4c,%eax
 73d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 740:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 744:	75 23                	jne    769 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 746:	c7 45 f0 44 0c 00 00 	movl   $0xc44,-0x10(%ebp)
 74d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 750:	a3 4c 0c 00 00       	mov    %eax,0xc4c
 755:	a1 4c 0c 00 00       	mov    0xc4c,%eax
 75a:	a3 44 0c 00 00       	mov    %eax,0xc44
    base.s.size = 0;
 75f:	c7 05 48 0c 00 00 00 	movl   $0x0,0xc48
 766:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 769:	8b 45 f0             	mov    -0x10(%ebp),%eax
 76c:	8b 00                	mov    (%eax),%eax
 76e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 771:	8b 45 f4             	mov    -0xc(%ebp),%eax
 774:	8b 40 04             	mov    0x4(%eax),%eax
 777:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 77a:	72 4d                	jb     7c9 <malloc+0xa6>
      if(p->s.size == nunits)
 77c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77f:	8b 40 04             	mov    0x4(%eax),%eax
 782:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 785:	75 0c                	jne    793 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 787:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78a:	8b 10                	mov    (%eax),%edx
 78c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 78f:	89 10                	mov    %edx,(%eax)
 791:	eb 26                	jmp    7b9 <malloc+0x96>
      else {
        p->s.size -= nunits;
 793:	8b 45 f4             	mov    -0xc(%ebp),%eax
 796:	8b 40 04             	mov    0x4(%eax),%eax
 799:	89 c2                	mov    %eax,%edx
 79b:	2b 55 ec             	sub    -0x14(%ebp),%edx
 79e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a7:	8b 40 04             	mov    0x4(%eax),%eax
 7aa:	c1 e0 03             	shl    $0x3,%eax
 7ad:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7b6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7bc:	a3 4c 0c 00 00       	mov    %eax,0xc4c
      return (void*)(p + 1);
 7c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c4:	83 c0 08             	add    $0x8,%eax
 7c7:	eb 38                	jmp    801 <malloc+0xde>
    }
    if(p == freep)
 7c9:	a1 4c 0c 00 00       	mov    0xc4c,%eax
 7ce:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7d1:	75 1b                	jne    7ee <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 7d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7d6:	89 04 24             	mov    %eax,(%esp)
 7d9:	e8 ed fe ff ff       	call   6cb <morecore>
 7de:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7e5:	75 07                	jne    7ee <malloc+0xcb>
        return 0;
 7e7:	b8 00 00 00 00       	mov    $0x0,%eax
 7ec:	eb 13                	jmp    801 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f7:	8b 00                	mov    (%eax),%eax
 7f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 7fc:	e9 70 ff ff ff       	jmp    771 <malloc+0x4e>
}
 801:	c9                   	leave  
 802:	c3                   	ret    
 803:	90                   	nop

00000804 <pthread_create>:
	clone's 3rd argument, *stek, should be allocated here?
*/

#define PAGESIZE (4096)  //Maybe 4092??

int pthread_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine) (void*), void *arg){
 804:	55                   	push   %ebp
 805:	89 e5                	mov    %esp,%ebp
 807:	83 ec 28             	sub    $0x28,%esp

	void *mystek = malloc((uint)PAGESIZE*2); //Why do we need the *2?
 80a:	c7 04 24 00 20 00 00 	movl   $0x2000,(%esp)
 811:	e8 0d ff ff ff       	call   723 <malloc>
 816:	89 45 f4             	mov    %eax,-0xc(%ebp)
//zzddhhtjzz/xv6/blob/master
	if((uint)mystek % PAGESIZE){
 819:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81c:	25 ff 0f 00 00       	and    $0xfff,%eax
 821:	85 c0                	test   %eax,%eax
 823:	74 15                	je     83a <pthread_create+0x36>
		mystek += 4096 - ((uint)mystek % PAGESIZE);
 825:	8b 45 f4             	mov    -0xc(%ebp),%eax
 828:	89 c2                	mov    %eax,%edx
 82a:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
 830:	b8 00 10 00 00       	mov    $0x1000,%eax
 835:	29 d0                	sub    %edx,%eax
 837:	01 45 f4             	add    %eax,-0xc(%ebp)
	}
	thread->pid = clone(start_routine, arg, mystek);
 83a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83d:	89 44 24 08          	mov    %eax,0x8(%esp)
 841:	8b 45 14             	mov    0x14(%ebp),%eax
 844:	89 44 24 04          	mov    %eax,0x4(%esp)
 848:	8b 45 10             	mov    0x10(%ebp),%eax
 84b:	89 04 24             	mov    %eax,(%esp)
 84e:	e8 dd fa ff ff       	call   330 <clone>
 853:	8b 55 08             	mov    0x8(%ebp),%edx
 856:	89 02                	mov    %eax,(%edx)
	return thread->pid;
 858:	8b 45 08             	mov    0x8(%ebp),%eax
 85b:	8b 00                	mov    (%eax),%eax
}
 85d:	c9                   	leave  
 85e:	c3                   	ret    

0000085f <pthread_join>:

int pthread_join(pthread_t thread, void **retval){
 85f:	55                   	push   %ebp
 860:	89 e5                	mov    %esp,%ebp
 862:	83 ec 28             	sub    $0x28,%esp

	void *stek;

	join((int)thread.pid, &stek, (void*)retval);
 865:	8b 45 08             	mov    0x8(%ebp),%eax
 868:	8b 55 0c             	mov    0xc(%ebp),%edx
 86b:	89 54 24 08          	mov    %edx,0x8(%esp)
 86f:	8d 55 f4             	lea    -0xc(%ebp),%edx
 872:	89 54 24 04          	mov    %edx,0x4(%esp)
 876:	89 04 24             	mov    %eax,(%esp)
 879:	e8 ba fa ff ff       	call   338 <join>

	free(stek);
 87e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 881:	89 04 24             	mov    %eax,(%esp)
 884:	e8 6b fd ff ff       	call   5f4 <free>

	return 0;
 889:	b8 00 00 00 00       	mov    $0x0,%eax
}
 88e:	c9                   	leave  
 88f:	c3                   	ret    

00000890 <pthread_exit>:

int pthread_exit(void *retval){
 890:	55                   	push   %ebp
 891:	89 e5                	mov    %esp,%ebp
 893:	83 ec 18             	sub    $0x18,%esp

	texit(retval);
 896:	8b 45 08             	mov    0x8(%ebp),%eax
 899:	89 04 24             	mov    %eax,(%esp)
 89c:	e8 9f fa ff ff       	call   340 <texit>

	return 0;
 8a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
 8a6:	c9                   	leave  
 8a7:	c3                   	ret    

000008a8 <pthread_mutex_init>:


int pthread_mutex_init(pthread_mutex_t *mutex, const pthread_mutex_attr_t *attr){
 8a8:	55                   	push   %ebp
 8a9:	89 e5                	mov    %esp,%ebp
 8ab:	83 ec 18             	sub    $0x18,%esp

	int mid = mutex_init();
 8ae:	e8 95 fa ff ff       	call   348 <mutex_init>
 8b3:	89 45 f4             	mov    %eax,-0xc(%ebp)

	//returns the id of the initalized mutex
	return mid;
 8b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
 8b9:	c9                   	leave  
 8ba:	c3                   	ret    

000008bb <pthread_mutex_destroy>:


int pthread_mutex_destroy(pthread_mutex_t *mutex){
 8bb:	55                   	push   %ebp
 8bc:	89 e5                	mov    %esp,%ebp
 8be:	83 ec 18             	sub    $0x18,%esp

	mutex_destroy(mutex->mid);
 8c1:	8b 45 08             	mov    0x8(%ebp),%eax
 8c4:	8b 40 04             	mov    0x4(%eax),%eax
 8c7:	89 04 24             	mov    %eax,(%esp)
 8ca:	e8 81 fa ff ff       	call   350 <mutex_destroy>
	return 0;
 8cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
 8d4:	c9                   	leave  
 8d5:	c3                   	ret    

000008d6 <pthread_mutex_lock>:


int pthread_mutex_lock(pthread_mutex_t *mutex){
 8d6:	55                   	push   %ebp
 8d7:	89 e5                	mov    %esp,%ebp
 8d9:	83 ec 18             	sub    $0x18,%esp

	mutex_lock(mutex->mid);
 8dc:	8b 45 08             	mov    0x8(%ebp),%eax
 8df:	8b 40 04             	mov    0x4(%eax),%eax
 8e2:	89 04 24             	mov    %eax,(%esp)
 8e5:	e8 6e fa ff ff       	call   358 <mutex_lock>
	return 0;
 8ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
 8ef:	c9                   	leave  
 8f0:	c3                   	ret    

000008f1 <pthread_mutex_unlock>:


int pthread_mutex_unlock(pthread_mutex_t *mutex){
 8f1:	55                   	push   %ebp
 8f2:	89 e5                	mov    %esp,%ebp
 8f4:	83 ec 18             	sub    $0x18,%esp

	mutex_unlock(mutex->mid);
 8f7:	8b 45 08             	mov    0x8(%ebp),%eax
 8fa:	8b 40 04             	mov    0x4(%eax),%eax
 8fd:	89 04 24             	mov    %eax,(%esp)
 900:	e8 5b fa ff ff       	call   360 <mutex_unlock>
	return 0;
 905:	b8 00 00 00 00       	mov    $0x0,%eax
 90a:	c9                   	leave  
 90b:	c3                   	ret    
