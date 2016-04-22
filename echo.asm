
_echo:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int i;

  for(i = 1; i < argc; i++)
   9:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  10:	00 
  11:	eb 45                	jmp    58 <main+0x58>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  13:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  17:	83 c0 01             	add    $0x1,%eax
  1a:	3b 45 08             	cmp    0x8(%ebp),%eax
  1d:	7d 07                	jge    26 <main+0x26>
  1f:	b8 50 09 00 00       	mov    $0x950,%eax
  24:	eb 05                	jmp    2b <main+0x2b>
  26:	b8 52 09 00 00       	mov    $0x952,%eax
  2b:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  2f:	c1 e2 02             	shl    $0x2,%edx
  32:	03 55 0c             	add    0xc(%ebp),%edx
  35:	8b 12                	mov    (%edx),%edx
  37:	89 44 24 0c          	mov    %eax,0xc(%esp)
  3b:	89 54 24 08          	mov    %edx,0x8(%esp)
  3f:	c7 44 24 04 54 09 00 	movl   $0x954,0x4(%esp)
  46:	00 
  47:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  4e:	e8 30 04 00 00       	call   483 <printf>
int
main(int argc, char *argv[])
{
  int i;

  for(i = 1; i < argc; i++)
  53:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
  58:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  5c:	3b 45 08             	cmp    0x8(%ebp),%eax
  5f:	7c b2                	jl     13 <main+0x13>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  exit();
  61:	e8 66 02 00 00       	call   2cc <exit>
  66:	90                   	nop
  67:	90                   	nop

00000068 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  68:	55                   	push   %ebp
  69:	89 e5                	mov    %esp,%ebp
  6b:	57                   	push   %edi
  6c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  70:	8b 55 10             	mov    0x10(%ebp),%edx
  73:	8b 45 0c             	mov    0xc(%ebp),%eax
  76:	89 cb                	mov    %ecx,%ebx
  78:	89 df                	mov    %ebx,%edi
  7a:	89 d1                	mov    %edx,%ecx
  7c:	fc                   	cld    
  7d:	f3 aa                	rep stos %al,%es:(%edi)
  7f:	89 ca                	mov    %ecx,%edx
  81:	89 fb                	mov    %edi,%ebx
  83:	89 5d 08             	mov    %ebx,0x8(%ebp)
  86:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  89:	5b                   	pop    %ebx
  8a:	5f                   	pop    %edi
  8b:	5d                   	pop    %ebp
  8c:	c3                   	ret    

0000008d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  8d:	55                   	push   %ebp
  8e:	89 e5                	mov    %esp,%ebp
  90:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  93:	8b 45 08             	mov    0x8(%ebp),%eax
  96:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  99:	90                   	nop
  9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  9d:	0f b6 10             	movzbl (%eax),%edx
  a0:	8b 45 08             	mov    0x8(%ebp),%eax
  a3:	88 10                	mov    %dl,(%eax)
  a5:	8b 45 08             	mov    0x8(%ebp),%eax
  a8:	0f b6 00             	movzbl (%eax),%eax
  ab:	84 c0                	test   %al,%al
  ad:	0f 95 c0             	setne  %al
  b0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  b4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  b8:	84 c0                	test   %al,%al
  ba:	75 de                	jne    9a <strcpy+0xd>
    ;
  return os;
  bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  bf:	c9                   	leave  
  c0:	c3                   	ret    

000000c1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c1:	55                   	push   %ebp
  c2:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  c4:	eb 08                	jmp    ce <strcmp+0xd>
    p++, q++;
  c6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  ca:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  ce:	8b 45 08             	mov    0x8(%ebp),%eax
  d1:	0f b6 00             	movzbl (%eax),%eax
  d4:	84 c0                	test   %al,%al
  d6:	74 10                	je     e8 <strcmp+0x27>
  d8:	8b 45 08             	mov    0x8(%ebp),%eax
  db:	0f b6 10             	movzbl (%eax),%edx
  de:	8b 45 0c             	mov    0xc(%ebp),%eax
  e1:	0f b6 00             	movzbl (%eax),%eax
  e4:	38 c2                	cmp    %al,%dl
  e6:	74 de                	je     c6 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  e8:	8b 45 08             	mov    0x8(%ebp),%eax
  eb:	0f b6 00             	movzbl (%eax),%eax
  ee:	0f b6 d0             	movzbl %al,%edx
  f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  f4:	0f b6 00             	movzbl (%eax),%eax
  f7:	0f b6 c0             	movzbl %al,%eax
  fa:	89 d1                	mov    %edx,%ecx
  fc:	29 c1                	sub    %eax,%ecx
  fe:	89 c8                	mov    %ecx,%eax
}
 100:	5d                   	pop    %ebp
 101:	c3                   	ret    

00000102 <strlen>:

uint
strlen(char *s)
{
 102:	55                   	push   %ebp
 103:	89 e5                	mov    %esp,%ebp
 105:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 108:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 10f:	eb 04                	jmp    115 <strlen+0x13>
 111:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 115:	8b 45 fc             	mov    -0x4(%ebp),%eax
 118:	03 45 08             	add    0x8(%ebp),%eax
 11b:	0f b6 00             	movzbl (%eax),%eax
 11e:	84 c0                	test   %al,%al
 120:	75 ef                	jne    111 <strlen+0xf>
    ;
  return n;
 122:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 125:	c9                   	leave  
 126:	c3                   	ret    

00000127 <memset>:

void*
memset(void *dst, int c, uint n)
{
 127:	55                   	push   %ebp
 128:	89 e5                	mov    %esp,%ebp
 12a:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 12d:	8b 45 10             	mov    0x10(%ebp),%eax
 130:	89 44 24 08          	mov    %eax,0x8(%esp)
 134:	8b 45 0c             	mov    0xc(%ebp),%eax
 137:	89 44 24 04          	mov    %eax,0x4(%esp)
 13b:	8b 45 08             	mov    0x8(%ebp),%eax
 13e:	89 04 24             	mov    %eax,(%esp)
 141:	e8 22 ff ff ff       	call   68 <stosb>
  return dst;
 146:	8b 45 08             	mov    0x8(%ebp),%eax
}
 149:	c9                   	leave  
 14a:	c3                   	ret    

0000014b <strchr>:

char*
strchr(const char *s, char c)
{
 14b:	55                   	push   %ebp
 14c:	89 e5                	mov    %esp,%ebp
 14e:	83 ec 04             	sub    $0x4,%esp
 151:	8b 45 0c             	mov    0xc(%ebp),%eax
 154:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 157:	eb 14                	jmp    16d <strchr+0x22>
    if(*s == c)
 159:	8b 45 08             	mov    0x8(%ebp),%eax
 15c:	0f b6 00             	movzbl (%eax),%eax
 15f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 162:	75 05                	jne    169 <strchr+0x1e>
      return (char*)s;
 164:	8b 45 08             	mov    0x8(%ebp),%eax
 167:	eb 13                	jmp    17c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 169:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 16d:	8b 45 08             	mov    0x8(%ebp),%eax
 170:	0f b6 00             	movzbl (%eax),%eax
 173:	84 c0                	test   %al,%al
 175:	75 e2                	jne    159 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 177:	b8 00 00 00 00       	mov    $0x0,%eax
}
 17c:	c9                   	leave  
 17d:	c3                   	ret    

0000017e <gets>:

char*
gets(char *buf, int max)
{
 17e:	55                   	push   %ebp
 17f:	89 e5                	mov    %esp,%ebp
 181:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 184:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 18b:	eb 44                	jmp    1d1 <gets+0x53>
    cc = read(0, &c, 1);
 18d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 194:	00 
 195:	8d 45 ef             	lea    -0x11(%ebp),%eax
 198:	89 44 24 04          	mov    %eax,0x4(%esp)
 19c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1a3:	e8 3c 01 00 00       	call   2e4 <read>
 1a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1af:	7e 2d                	jle    1de <gets+0x60>
      break;
    buf[i++] = c;
 1b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b4:	03 45 08             	add    0x8(%ebp),%eax
 1b7:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 1bb:	88 10                	mov    %dl,(%eax)
 1bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 1c1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c5:	3c 0a                	cmp    $0xa,%al
 1c7:	74 16                	je     1df <gets+0x61>
 1c9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1cd:	3c 0d                	cmp    $0xd,%al
 1cf:	74 0e                	je     1df <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d4:	83 c0 01             	add    $0x1,%eax
 1d7:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1da:	7c b1                	jl     18d <gets+0xf>
 1dc:	eb 01                	jmp    1df <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1de:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e2:	03 45 08             	add    0x8(%ebp),%eax
 1e5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1e8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1eb:	c9                   	leave  
 1ec:	c3                   	ret    

000001ed <stat>:

int
stat(char *n, struct stat *st)
{
 1ed:	55                   	push   %ebp
 1ee:	89 e5                	mov    %esp,%ebp
 1f0:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1fa:	00 
 1fb:	8b 45 08             	mov    0x8(%ebp),%eax
 1fe:	89 04 24             	mov    %eax,(%esp)
 201:	e8 06 01 00 00       	call   30c <open>
 206:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 209:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 20d:	79 07                	jns    216 <stat+0x29>
    return -1;
 20f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 214:	eb 23                	jmp    239 <stat+0x4c>
  r = fstat(fd, st);
 216:	8b 45 0c             	mov    0xc(%ebp),%eax
 219:	89 44 24 04          	mov    %eax,0x4(%esp)
 21d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 220:	89 04 24             	mov    %eax,(%esp)
 223:	e8 fc 00 00 00       	call   324 <fstat>
 228:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 22b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 22e:	89 04 24             	mov    %eax,(%esp)
 231:	e8 be 00 00 00       	call   2f4 <close>
  return r;
 236:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 239:	c9                   	leave  
 23a:	c3                   	ret    

0000023b <atoi>:

int
atoi(const char *s)
{
 23b:	55                   	push   %ebp
 23c:	89 e5                	mov    %esp,%ebp
 23e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 241:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 248:	eb 23                	jmp    26d <atoi+0x32>
    n = n*10 + *s++ - '0';
 24a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 24d:	89 d0                	mov    %edx,%eax
 24f:	c1 e0 02             	shl    $0x2,%eax
 252:	01 d0                	add    %edx,%eax
 254:	01 c0                	add    %eax,%eax
 256:	89 c2                	mov    %eax,%edx
 258:	8b 45 08             	mov    0x8(%ebp),%eax
 25b:	0f b6 00             	movzbl (%eax),%eax
 25e:	0f be c0             	movsbl %al,%eax
 261:	01 d0                	add    %edx,%eax
 263:	83 e8 30             	sub    $0x30,%eax
 266:	89 45 fc             	mov    %eax,-0x4(%ebp)
 269:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 26d:	8b 45 08             	mov    0x8(%ebp),%eax
 270:	0f b6 00             	movzbl (%eax),%eax
 273:	3c 2f                	cmp    $0x2f,%al
 275:	7e 0a                	jle    281 <atoi+0x46>
 277:	8b 45 08             	mov    0x8(%ebp),%eax
 27a:	0f b6 00             	movzbl (%eax),%eax
 27d:	3c 39                	cmp    $0x39,%al
 27f:	7e c9                	jle    24a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 281:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 284:	c9                   	leave  
 285:	c3                   	ret    

00000286 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 286:	55                   	push   %ebp
 287:	89 e5                	mov    %esp,%ebp
 289:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 28c:	8b 45 08             	mov    0x8(%ebp),%eax
 28f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 292:	8b 45 0c             	mov    0xc(%ebp),%eax
 295:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 298:	eb 13                	jmp    2ad <memmove+0x27>
    *dst++ = *src++;
 29a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 29d:	0f b6 10             	movzbl (%eax),%edx
 2a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2a3:	88 10                	mov    %dl,(%eax)
 2a5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2a9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2ad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 2b1:	0f 9f c0             	setg   %al
 2b4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 2b8:	84 c0                	test   %al,%al
 2ba:	75 de                	jne    29a <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2bc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2bf:	c9                   	leave  
 2c0:	c3                   	ret    
 2c1:	90                   	nop
 2c2:	90                   	nop
 2c3:	90                   	nop

000002c4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2c4:	b8 01 00 00 00       	mov    $0x1,%eax
 2c9:	cd 40                	int    $0x40
 2cb:	c3                   	ret    

000002cc <exit>:
SYSCALL(exit)
 2cc:	b8 02 00 00 00       	mov    $0x2,%eax
 2d1:	cd 40                	int    $0x40
 2d3:	c3                   	ret    

000002d4 <wait>:
SYSCALL(wait)
 2d4:	b8 03 00 00 00       	mov    $0x3,%eax
 2d9:	cd 40                	int    $0x40
 2db:	c3                   	ret    

000002dc <pipe>:
SYSCALL(pipe)
 2dc:	b8 04 00 00 00       	mov    $0x4,%eax
 2e1:	cd 40                	int    $0x40
 2e3:	c3                   	ret    

000002e4 <read>:
SYSCALL(read)
 2e4:	b8 05 00 00 00       	mov    $0x5,%eax
 2e9:	cd 40                	int    $0x40
 2eb:	c3                   	ret    

000002ec <write>:
SYSCALL(write)
 2ec:	b8 10 00 00 00       	mov    $0x10,%eax
 2f1:	cd 40                	int    $0x40
 2f3:	c3                   	ret    

000002f4 <close>:
SYSCALL(close)
 2f4:	b8 15 00 00 00       	mov    $0x15,%eax
 2f9:	cd 40                	int    $0x40
 2fb:	c3                   	ret    

000002fc <kill>:
SYSCALL(kill)
 2fc:	b8 06 00 00 00       	mov    $0x6,%eax
 301:	cd 40                	int    $0x40
 303:	c3                   	ret    

00000304 <exec>:
SYSCALL(exec)
 304:	b8 07 00 00 00       	mov    $0x7,%eax
 309:	cd 40                	int    $0x40
 30b:	c3                   	ret    

0000030c <open>:
SYSCALL(open)
 30c:	b8 0f 00 00 00       	mov    $0xf,%eax
 311:	cd 40                	int    $0x40
 313:	c3                   	ret    

00000314 <mknod>:
SYSCALL(mknod)
 314:	b8 11 00 00 00       	mov    $0x11,%eax
 319:	cd 40                	int    $0x40
 31b:	c3                   	ret    

0000031c <unlink>:
SYSCALL(unlink)
 31c:	b8 12 00 00 00       	mov    $0x12,%eax
 321:	cd 40                	int    $0x40
 323:	c3                   	ret    

00000324 <fstat>:
SYSCALL(fstat)
 324:	b8 08 00 00 00       	mov    $0x8,%eax
 329:	cd 40                	int    $0x40
 32b:	c3                   	ret    

0000032c <link>:
SYSCALL(link)
 32c:	b8 13 00 00 00       	mov    $0x13,%eax
 331:	cd 40                	int    $0x40
 333:	c3                   	ret    

00000334 <mkdir>:
SYSCALL(mkdir)
 334:	b8 14 00 00 00       	mov    $0x14,%eax
 339:	cd 40                	int    $0x40
 33b:	c3                   	ret    

0000033c <chdir>:
SYSCALL(chdir)
 33c:	b8 09 00 00 00       	mov    $0x9,%eax
 341:	cd 40                	int    $0x40
 343:	c3                   	ret    

00000344 <dup>:
SYSCALL(dup)
 344:	b8 0a 00 00 00       	mov    $0xa,%eax
 349:	cd 40                	int    $0x40
 34b:	c3                   	ret    

0000034c <getpid>:
SYSCALL(getpid)
 34c:	b8 0b 00 00 00       	mov    $0xb,%eax
 351:	cd 40                	int    $0x40
 353:	c3                   	ret    

00000354 <sbrk>:
SYSCALL(sbrk)
 354:	b8 0c 00 00 00       	mov    $0xc,%eax
 359:	cd 40                	int    $0x40
 35b:	c3                   	ret    

0000035c <sleep>:
SYSCALL(sleep)
 35c:	b8 0d 00 00 00       	mov    $0xd,%eax
 361:	cd 40                	int    $0x40
 363:	c3                   	ret    

00000364 <uptime>:
SYSCALL(uptime)
 364:	b8 0e 00 00 00       	mov    $0xe,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret    

0000036c <halt>:
SYSCALL(halt)
 36c:	b8 16 00 00 00       	mov    $0x16,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <clone>:

SYSCALL(clone)
 374:	b8 19 00 00 00       	mov    $0x19,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <join>:
SYSCALL(join)
 37c:	b8 1a 00 00 00       	mov    $0x1a,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <texit>:
SYSCALL(texit)
 384:	b8 1b 00 00 00       	mov    $0x1b,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret    

0000038c <mutex_init>:
SYSCALL(mutex_init)
 38c:	b8 1c 00 00 00       	mov    $0x1c,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret    

00000394 <mutex_destroy>:
SYSCALL(mutex_destroy)
 394:	b8 1d 00 00 00       	mov    $0x1d,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <mutex_lock>:
SYSCALL(mutex_lock)
 39c:	b8 1e 00 00 00       	mov    $0x1e,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret    

000003a4 <mutex_unlock>:
 3a4:	b8 1f 00 00 00       	mov    $0x1f,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3ac:	55                   	push   %ebp
 3ad:	89 e5                	mov    %esp,%ebp
 3af:	83 ec 28             	sub    $0x28,%esp
 3b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b5:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3b8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3bf:	00 
 3c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3c3:	89 44 24 04          	mov    %eax,0x4(%esp)
 3c7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ca:	89 04 24             	mov    %eax,(%esp)
 3cd:	e8 1a ff ff ff       	call   2ec <write>
}
 3d2:	c9                   	leave  
 3d3:	c3                   	ret    

000003d4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3d4:	55                   	push   %ebp
 3d5:	89 e5                	mov    %esp,%ebp
 3d7:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3da:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3e1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3e5:	74 17                	je     3fe <printint+0x2a>
 3e7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3eb:	79 11                	jns    3fe <printint+0x2a>
    neg = 1;
 3ed:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3f4:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f7:	f7 d8                	neg    %eax
 3f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3fc:	eb 06                	jmp    404 <printint+0x30>
  } else {
    x = xx;
 3fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 401:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 40b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 40e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 411:	ba 00 00 00 00       	mov    $0x0,%edx
 416:	f7 f1                	div    %ecx
 418:	89 d0                	mov    %edx,%eax
 41a:	0f b6 90 7c 0c 00 00 	movzbl 0xc7c(%eax),%edx
 421:	8d 45 dc             	lea    -0x24(%ebp),%eax
 424:	03 45 f4             	add    -0xc(%ebp),%eax
 427:	88 10                	mov    %dl,(%eax)
 429:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 42d:	8b 55 10             	mov    0x10(%ebp),%edx
 430:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 433:	8b 45 ec             	mov    -0x14(%ebp),%eax
 436:	ba 00 00 00 00       	mov    $0x0,%edx
 43b:	f7 75 d4             	divl   -0x2c(%ebp)
 43e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 441:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 445:	75 c4                	jne    40b <printint+0x37>
  if(neg)
 447:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 44b:	74 2a                	je     477 <printint+0xa3>
    buf[i++] = '-';
 44d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 450:	03 45 f4             	add    -0xc(%ebp),%eax
 453:	c6 00 2d             	movb   $0x2d,(%eax)
 456:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 45a:	eb 1b                	jmp    477 <printint+0xa3>
    putc(fd, buf[i]);
 45c:	8d 45 dc             	lea    -0x24(%ebp),%eax
 45f:	03 45 f4             	add    -0xc(%ebp),%eax
 462:	0f b6 00             	movzbl (%eax),%eax
 465:	0f be c0             	movsbl %al,%eax
 468:	89 44 24 04          	mov    %eax,0x4(%esp)
 46c:	8b 45 08             	mov    0x8(%ebp),%eax
 46f:	89 04 24             	mov    %eax,(%esp)
 472:	e8 35 ff ff ff       	call   3ac <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 477:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 47b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 47f:	79 db                	jns    45c <printint+0x88>
    putc(fd, buf[i]);
}
 481:	c9                   	leave  
 482:	c3                   	ret    

00000483 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 483:	55                   	push   %ebp
 484:	89 e5                	mov    %esp,%ebp
 486:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 489:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 490:	8d 45 0c             	lea    0xc(%ebp),%eax
 493:	83 c0 04             	add    $0x4,%eax
 496:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 499:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4a0:	e9 7d 01 00 00       	jmp    622 <printf+0x19f>
    c = fmt[i] & 0xff;
 4a5:	8b 55 0c             	mov    0xc(%ebp),%edx
 4a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4ab:	01 d0                	add    %edx,%eax
 4ad:	0f b6 00             	movzbl (%eax),%eax
 4b0:	0f be c0             	movsbl %al,%eax
 4b3:	25 ff 00 00 00       	and    $0xff,%eax
 4b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4bb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4bf:	75 2c                	jne    4ed <printf+0x6a>
      if(c == '%'){
 4c1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4c5:	75 0c                	jne    4d3 <printf+0x50>
        state = '%';
 4c7:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4ce:	e9 4b 01 00 00       	jmp    61e <printf+0x19b>
      } else {
        putc(fd, c);
 4d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4d6:	0f be c0             	movsbl %al,%eax
 4d9:	89 44 24 04          	mov    %eax,0x4(%esp)
 4dd:	8b 45 08             	mov    0x8(%ebp),%eax
 4e0:	89 04 24             	mov    %eax,(%esp)
 4e3:	e8 c4 fe ff ff       	call   3ac <putc>
 4e8:	e9 31 01 00 00       	jmp    61e <printf+0x19b>
      }
    } else if(state == '%'){
 4ed:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4f1:	0f 85 27 01 00 00    	jne    61e <printf+0x19b>
      if(c == 'd'){
 4f7:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4fb:	75 2d                	jne    52a <printf+0xa7>
        printint(fd, *ap, 10, 1);
 4fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 500:	8b 00                	mov    (%eax),%eax
 502:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 509:	00 
 50a:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 511:	00 
 512:	89 44 24 04          	mov    %eax,0x4(%esp)
 516:	8b 45 08             	mov    0x8(%ebp),%eax
 519:	89 04 24             	mov    %eax,(%esp)
 51c:	e8 b3 fe ff ff       	call   3d4 <printint>
        ap++;
 521:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 525:	e9 ed 00 00 00       	jmp    617 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 52a:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 52e:	74 06                	je     536 <printf+0xb3>
 530:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 534:	75 2d                	jne    563 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 536:	8b 45 e8             	mov    -0x18(%ebp),%eax
 539:	8b 00                	mov    (%eax),%eax
 53b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 542:	00 
 543:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 54a:	00 
 54b:	89 44 24 04          	mov    %eax,0x4(%esp)
 54f:	8b 45 08             	mov    0x8(%ebp),%eax
 552:	89 04 24             	mov    %eax,(%esp)
 555:	e8 7a fe ff ff       	call   3d4 <printint>
        ap++;
 55a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 55e:	e9 b4 00 00 00       	jmp    617 <printf+0x194>
      } else if(c == 's'){
 563:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 567:	75 46                	jne    5af <printf+0x12c>
        s = (char*)*ap;
 569:	8b 45 e8             	mov    -0x18(%ebp),%eax
 56c:	8b 00                	mov    (%eax),%eax
 56e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 571:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 575:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 579:	75 27                	jne    5a2 <printf+0x11f>
          s = "(null)";
 57b:	c7 45 f4 59 09 00 00 	movl   $0x959,-0xc(%ebp)
        while(*s != 0){
 582:	eb 1e                	jmp    5a2 <printf+0x11f>
          putc(fd, *s);
 584:	8b 45 f4             	mov    -0xc(%ebp),%eax
 587:	0f b6 00             	movzbl (%eax),%eax
 58a:	0f be c0             	movsbl %al,%eax
 58d:	89 44 24 04          	mov    %eax,0x4(%esp)
 591:	8b 45 08             	mov    0x8(%ebp),%eax
 594:	89 04 24             	mov    %eax,(%esp)
 597:	e8 10 fe ff ff       	call   3ac <putc>
          s++;
 59c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 5a0:	eb 01                	jmp    5a3 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5a2:	90                   	nop
 5a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5a6:	0f b6 00             	movzbl (%eax),%eax
 5a9:	84 c0                	test   %al,%al
 5ab:	75 d7                	jne    584 <printf+0x101>
 5ad:	eb 68                	jmp    617 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5af:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5b3:	75 1d                	jne    5d2 <printf+0x14f>
        putc(fd, *ap);
 5b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b8:	8b 00                	mov    (%eax),%eax
 5ba:	0f be c0             	movsbl %al,%eax
 5bd:	89 44 24 04          	mov    %eax,0x4(%esp)
 5c1:	8b 45 08             	mov    0x8(%ebp),%eax
 5c4:	89 04 24             	mov    %eax,(%esp)
 5c7:	e8 e0 fd ff ff       	call   3ac <putc>
        ap++;
 5cc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5d0:	eb 45                	jmp    617 <printf+0x194>
      } else if(c == '%'){
 5d2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5d6:	75 17                	jne    5ef <printf+0x16c>
        putc(fd, c);
 5d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5db:	0f be c0             	movsbl %al,%eax
 5de:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e2:	8b 45 08             	mov    0x8(%ebp),%eax
 5e5:	89 04 24             	mov    %eax,(%esp)
 5e8:	e8 bf fd ff ff       	call   3ac <putc>
 5ed:	eb 28                	jmp    617 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5ef:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 5f6:	00 
 5f7:	8b 45 08             	mov    0x8(%ebp),%eax
 5fa:	89 04 24             	mov    %eax,(%esp)
 5fd:	e8 aa fd ff ff       	call   3ac <putc>
        putc(fd, c);
 602:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 605:	0f be c0             	movsbl %al,%eax
 608:	89 44 24 04          	mov    %eax,0x4(%esp)
 60c:	8b 45 08             	mov    0x8(%ebp),%eax
 60f:	89 04 24             	mov    %eax,(%esp)
 612:	e8 95 fd ff ff       	call   3ac <putc>
      }
      state = 0;
 617:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 61e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 622:	8b 55 0c             	mov    0xc(%ebp),%edx
 625:	8b 45 f0             	mov    -0x10(%ebp),%eax
 628:	01 d0                	add    %edx,%eax
 62a:	0f b6 00             	movzbl (%eax),%eax
 62d:	84 c0                	test   %al,%al
 62f:	0f 85 70 fe ff ff    	jne    4a5 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 635:	c9                   	leave  
 636:	c3                   	ret    
 637:	90                   	nop

00000638 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 638:	55                   	push   %ebp
 639:	89 e5                	mov    %esp,%ebp
 63b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 63e:	8b 45 08             	mov    0x8(%ebp),%eax
 641:	83 e8 08             	sub    $0x8,%eax
 644:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 647:	a1 98 0c 00 00       	mov    0xc98,%eax
 64c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 64f:	eb 24                	jmp    675 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 651:	8b 45 fc             	mov    -0x4(%ebp),%eax
 654:	8b 00                	mov    (%eax),%eax
 656:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 659:	77 12                	ja     66d <free+0x35>
 65b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 661:	77 24                	ja     687 <free+0x4f>
 663:	8b 45 fc             	mov    -0x4(%ebp),%eax
 666:	8b 00                	mov    (%eax),%eax
 668:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 66b:	77 1a                	ja     687 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 66d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 670:	8b 00                	mov    (%eax),%eax
 672:	89 45 fc             	mov    %eax,-0x4(%ebp)
 675:	8b 45 f8             	mov    -0x8(%ebp),%eax
 678:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 67b:	76 d4                	jbe    651 <free+0x19>
 67d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 680:	8b 00                	mov    (%eax),%eax
 682:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 685:	76 ca                	jbe    651 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 687:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68a:	8b 40 04             	mov    0x4(%eax),%eax
 68d:	c1 e0 03             	shl    $0x3,%eax
 690:	89 c2                	mov    %eax,%edx
 692:	03 55 f8             	add    -0x8(%ebp),%edx
 695:	8b 45 fc             	mov    -0x4(%ebp),%eax
 698:	8b 00                	mov    (%eax),%eax
 69a:	39 c2                	cmp    %eax,%edx
 69c:	75 24                	jne    6c2 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 69e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a1:	8b 50 04             	mov    0x4(%eax),%edx
 6a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a7:	8b 00                	mov    (%eax),%eax
 6a9:	8b 40 04             	mov    0x4(%eax),%eax
 6ac:	01 c2                	add    %eax,%edx
 6ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b1:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b7:	8b 00                	mov    (%eax),%eax
 6b9:	8b 10                	mov    (%eax),%edx
 6bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6be:	89 10                	mov    %edx,(%eax)
 6c0:	eb 0a                	jmp    6cc <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 6c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c5:	8b 10                	mov    (%eax),%edx
 6c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ca:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cf:	8b 40 04             	mov    0x4(%eax),%eax
 6d2:	c1 e0 03             	shl    $0x3,%eax
 6d5:	03 45 fc             	add    -0x4(%ebp),%eax
 6d8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6db:	75 20                	jne    6fd <free+0xc5>
    p->s.size += bp->s.size;
 6dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e0:	8b 50 04             	mov    0x4(%eax),%edx
 6e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e6:	8b 40 04             	mov    0x4(%eax),%eax
 6e9:	01 c2                	add    %eax,%edx
 6eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ee:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f4:	8b 10                	mov    (%eax),%edx
 6f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f9:	89 10                	mov    %edx,(%eax)
 6fb:	eb 08                	jmp    705 <free+0xcd>
  } else
    p->s.ptr = bp;
 6fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 700:	8b 55 f8             	mov    -0x8(%ebp),%edx
 703:	89 10                	mov    %edx,(%eax)
  freep = p;
 705:	8b 45 fc             	mov    -0x4(%ebp),%eax
 708:	a3 98 0c 00 00       	mov    %eax,0xc98
}
 70d:	c9                   	leave  
 70e:	c3                   	ret    

0000070f <morecore>:

static Header*
morecore(uint nu)
{
 70f:	55                   	push   %ebp
 710:	89 e5                	mov    %esp,%ebp
 712:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 715:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 71c:	77 07                	ja     725 <morecore+0x16>
    nu = 4096;
 71e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 725:	8b 45 08             	mov    0x8(%ebp),%eax
 728:	c1 e0 03             	shl    $0x3,%eax
 72b:	89 04 24             	mov    %eax,(%esp)
 72e:	e8 21 fc ff ff       	call   354 <sbrk>
 733:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 736:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 73a:	75 07                	jne    743 <morecore+0x34>
    return 0;
 73c:	b8 00 00 00 00       	mov    $0x0,%eax
 741:	eb 22                	jmp    765 <morecore+0x56>
  hp = (Header*)p;
 743:	8b 45 f4             	mov    -0xc(%ebp),%eax
 746:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 749:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74c:	8b 55 08             	mov    0x8(%ebp),%edx
 74f:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 752:	8b 45 f0             	mov    -0x10(%ebp),%eax
 755:	83 c0 08             	add    $0x8,%eax
 758:	89 04 24             	mov    %eax,(%esp)
 75b:	e8 d8 fe ff ff       	call   638 <free>
  return freep;
 760:	a1 98 0c 00 00       	mov    0xc98,%eax
}
 765:	c9                   	leave  
 766:	c3                   	ret    

00000767 <malloc>:

void*
malloc(uint nbytes)
{
 767:	55                   	push   %ebp
 768:	89 e5                	mov    %esp,%ebp
 76a:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 76d:	8b 45 08             	mov    0x8(%ebp),%eax
 770:	83 c0 07             	add    $0x7,%eax
 773:	c1 e8 03             	shr    $0x3,%eax
 776:	83 c0 01             	add    $0x1,%eax
 779:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 77c:	a1 98 0c 00 00       	mov    0xc98,%eax
 781:	89 45 f0             	mov    %eax,-0x10(%ebp)
 784:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 788:	75 23                	jne    7ad <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 78a:	c7 45 f0 90 0c 00 00 	movl   $0xc90,-0x10(%ebp)
 791:	8b 45 f0             	mov    -0x10(%ebp),%eax
 794:	a3 98 0c 00 00       	mov    %eax,0xc98
 799:	a1 98 0c 00 00       	mov    0xc98,%eax
 79e:	a3 90 0c 00 00       	mov    %eax,0xc90
    base.s.size = 0;
 7a3:	c7 05 94 0c 00 00 00 	movl   $0x0,0xc94
 7aa:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b0:	8b 00                	mov    (%eax),%eax
 7b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b8:	8b 40 04             	mov    0x4(%eax),%eax
 7bb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7be:	72 4d                	jb     80d <malloc+0xa6>
      if(p->s.size == nunits)
 7c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c3:	8b 40 04             	mov    0x4(%eax),%eax
 7c6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7c9:	75 0c                	jne    7d7 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ce:	8b 10                	mov    (%eax),%edx
 7d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d3:	89 10                	mov    %edx,(%eax)
 7d5:	eb 26                	jmp    7fd <malloc+0x96>
      else {
        p->s.size -= nunits;
 7d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7da:	8b 40 04             	mov    0x4(%eax),%eax
 7dd:	89 c2                	mov    %eax,%edx
 7df:	2b 55 ec             	sub    -0x14(%ebp),%edx
 7e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e5:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7eb:	8b 40 04             	mov    0x4(%eax),%eax
 7ee:	c1 e0 03             	shl    $0x3,%eax
 7f1:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f7:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7fa:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 800:	a3 98 0c 00 00       	mov    %eax,0xc98
      return (void*)(p + 1);
 805:	8b 45 f4             	mov    -0xc(%ebp),%eax
 808:	83 c0 08             	add    $0x8,%eax
 80b:	eb 38                	jmp    845 <malloc+0xde>
    }
    if(p == freep)
 80d:	a1 98 0c 00 00       	mov    0xc98,%eax
 812:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 815:	75 1b                	jne    832 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 817:	8b 45 ec             	mov    -0x14(%ebp),%eax
 81a:	89 04 24             	mov    %eax,(%esp)
 81d:	e8 ed fe ff ff       	call   70f <morecore>
 822:	89 45 f4             	mov    %eax,-0xc(%ebp)
 825:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 829:	75 07                	jne    832 <malloc+0xcb>
        return 0;
 82b:	b8 00 00 00 00       	mov    $0x0,%eax
 830:	eb 13                	jmp    845 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 832:	8b 45 f4             	mov    -0xc(%ebp),%eax
 835:	89 45 f0             	mov    %eax,-0x10(%ebp)
 838:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83b:	8b 00                	mov    (%eax),%eax
 83d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 840:	e9 70 ff ff ff       	jmp    7b5 <malloc+0x4e>
}
 845:	c9                   	leave  
 846:	c3                   	ret    
 847:	90                   	nop

00000848 <pthread_create>:
	clone's 3rd argument, *stek, should be allocated here?
*/

#define PAGESIZE (4096)  //Maybe 4092??

int pthread_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine) (void*), void *arg){
 848:	55                   	push   %ebp
 849:	89 e5                	mov    %esp,%ebp
 84b:	83 ec 28             	sub    $0x28,%esp

	void *mystek = malloc((uint)PAGESIZE*2); //Why do we need the *2?
 84e:	c7 04 24 00 20 00 00 	movl   $0x2000,(%esp)
 855:	e8 0d ff ff ff       	call   767 <malloc>
 85a:	89 45 f4             	mov    %eax,-0xc(%ebp)
//zzddhhtjzz/xv6/blob/master
	if((uint)mystek % PAGESIZE){
 85d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 860:	25 ff 0f 00 00       	and    $0xfff,%eax
 865:	85 c0                	test   %eax,%eax
 867:	74 15                	je     87e <pthread_create+0x36>
		mystek += 4096 - ((uint)mystek % PAGESIZE);
 869:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86c:	89 c2                	mov    %eax,%edx
 86e:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
 874:	b8 00 10 00 00       	mov    $0x1000,%eax
 879:	29 d0                	sub    %edx,%eax
 87b:	01 45 f4             	add    %eax,-0xc(%ebp)
	}
	thread->pid = clone(start_routine, arg, mystek);
 87e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 881:	89 44 24 08          	mov    %eax,0x8(%esp)
 885:	8b 45 14             	mov    0x14(%ebp),%eax
 888:	89 44 24 04          	mov    %eax,0x4(%esp)
 88c:	8b 45 10             	mov    0x10(%ebp),%eax
 88f:	89 04 24             	mov    %eax,(%esp)
 892:	e8 dd fa ff ff       	call   374 <clone>
 897:	8b 55 08             	mov    0x8(%ebp),%edx
 89a:	89 02                	mov    %eax,(%edx)
	return thread->pid;
 89c:	8b 45 08             	mov    0x8(%ebp),%eax
 89f:	8b 00                	mov    (%eax),%eax
}
 8a1:	c9                   	leave  
 8a2:	c3                   	ret    

000008a3 <pthread_join>:

int pthread_join(pthread_t thread, void **retval){
 8a3:	55                   	push   %ebp
 8a4:	89 e5                	mov    %esp,%ebp
 8a6:	83 ec 28             	sub    $0x28,%esp

	void *stek;

	join((int)thread.pid, &stek, (void*)retval);
 8a9:	8b 45 08             	mov    0x8(%ebp),%eax
 8ac:	8b 55 0c             	mov    0xc(%ebp),%edx
 8af:	89 54 24 08          	mov    %edx,0x8(%esp)
 8b3:	8d 55 f4             	lea    -0xc(%ebp),%edx
 8b6:	89 54 24 04          	mov    %edx,0x4(%esp)
 8ba:	89 04 24             	mov    %eax,(%esp)
 8bd:	e8 ba fa ff ff       	call   37c <join>

	free(stek);
 8c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c5:	89 04 24             	mov    %eax,(%esp)
 8c8:	e8 6b fd ff ff       	call   638 <free>

	return 0;
 8cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
 8d2:	c9                   	leave  
 8d3:	c3                   	ret    

000008d4 <pthread_exit>:

int pthread_exit(void *retval){
 8d4:	55                   	push   %ebp
 8d5:	89 e5                	mov    %esp,%ebp
 8d7:	83 ec 18             	sub    $0x18,%esp

	texit(retval);
 8da:	8b 45 08             	mov    0x8(%ebp),%eax
 8dd:	89 04 24             	mov    %eax,(%esp)
 8e0:	e8 9f fa ff ff       	call   384 <texit>

	return 0;
 8e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
 8ea:	c9                   	leave  
 8eb:	c3                   	ret    

000008ec <pthread_mutex_init>:


int pthread_mutex_init(pthread_mutex_t *mutex, const pthread_mutex_attr_t *attr){
 8ec:	55                   	push   %ebp
 8ed:	89 e5                	mov    %esp,%ebp
 8ef:	83 ec 18             	sub    $0x18,%esp

	int mid = mutex_init();
 8f2:	e8 95 fa ff ff       	call   38c <mutex_init>
 8f7:	89 45 f4             	mov    %eax,-0xc(%ebp)

	//returns the id of the initalized mutex
	return mid;
 8fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
 8fd:	c9                   	leave  
 8fe:	c3                   	ret    

000008ff <pthread_mutex_destroy>:


int pthread_mutex_destroy(pthread_mutex_t *mutex){
 8ff:	55                   	push   %ebp
 900:	89 e5                	mov    %esp,%ebp
 902:	83 ec 18             	sub    $0x18,%esp

	//flag this mutex as destroyed
	mutex_destroy(mutex->mid);
 905:	8b 45 08             	mov    0x8(%ebp),%eax
 908:	8b 40 04             	mov    0x4(%eax),%eax
 90b:	89 04 24             	mov    %eax,(%esp)
 90e:	e8 81 fa ff ff       	call   394 <mutex_destroy>
	return 0;
 913:	b8 00 00 00 00       	mov    $0x0,%eax
}
 918:	c9                   	leave  
 919:	c3                   	ret    

0000091a <pthread_mutex_lock>:


int pthread_mutex_lock(pthread_mutex_t *mutex){
 91a:	55                   	push   %ebp
 91b:	89 e5                	mov    %esp,%ebp
 91d:	83 ec 18             	sub    $0x18,%esp

	mutex_lock(mutex->mid);
 920:	8b 45 08             	mov    0x8(%ebp),%eax
 923:	8b 40 04             	mov    0x4(%eax),%eax
 926:	89 04 24             	mov    %eax,(%esp)
 929:	e8 6e fa ff ff       	call   39c <mutex_lock>
	return 0;
 92e:	b8 00 00 00 00       	mov    $0x0,%eax
}
 933:	c9                   	leave  
 934:	c3                   	ret    

00000935 <pthread_mutex_unlock>:


int pthread_mutex_unlock(pthread_mutex_t *mutex){
 935:	55                   	push   %ebp
 936:	89 e5                	mov    %esp,%ebp
 938:	83 ec 18             	sub    $0x18,%esp

	mutex_unlock(mutex->mid);
 93b:	8b 45 08             	mov    0x8(%ebp),%eax
 93e:	8b 40 04             	mov    0x4(%eax),%eax
 941:	89 04 24             	mov    %eax,(%esp)
 944:	e8 5b fa ff ff       	call   3a4 <mutex_unlock>
	return 0;
 949:	b8 00 00 00 00       	mov    $0x0,%eax
 94e:	c9                   	leave  
 94f:	c3                   	ret    
