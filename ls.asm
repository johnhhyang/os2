
_ls:     file format elf32-i386


Disassembly of section .text:

00000000 <fmtname>:
#include "user.h"
#include "fs.h"

char*
fmtname(char *path)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 24             	sub    $0x24,%esp
  static char buf[DIRSIZ+1];
  char *p;
  
  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   7:	8b 45 08             	mov    0x8(%ebp),%eax
   a:	89 04 24             	mov    %eax,(%esp)
   d:	e8 dc 03 00 00       	call   3ee <strlen>
  12:	03 45 08             	add    0x8(%ebp),%eax
  15:	89 45 f4             	mov    %eax,-0xc(%ebp)
  18:	eb 04                	jmp    1e <fmtname+0x1e>
  1a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  21:	3b 45 08             	cmp    0x8(%ebp),%eax
  24:	72 0a                	jb     30 <fmtname+0x30>
  26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  29:	0f b6 00             	movzbl (%eax),%eax
  2c:	3c 2f                	cmp    $0x2f,%al
  2e:	75 ea                	jne    1a <fmtname+0x1a>
    ;
  p++;
  30:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  37:	89 04 24             	mov    %eax,(%esp)
  3a:	e8 af 03 00 00       	call   3ee <strlen>
  3f:	83 f8 0d             	cmp    $0xd,%eax
  42:	76 05                	jbe    49 <fmtname+0x49>
    return p;
  44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  47:	eb 5f                	jmp    a8 <fmtname+0xa8>
  memmove(buf, p, strlen(p));
  49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4c:	89 04 24             	mov    %eax,(%esp)
  4f:	e8 9a 03 00 00       	call   3ee <strlen>
  54:	89 44 24 08          	mov    %eax,0x8(%esp)
  58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  5f:	c7 04 24 14 10 00 00 	movl   $0x1014,(%esp)
  66:	e8 07 05 00 00       	call   572 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  6e:	89 04 24             	mov    %eax,(%esp)
  71:	e8 78 03 00 00       	call   3ee <strlen>
  76:	ba 0e 00 00 00       	mov    $0xe,%edx
  7b:	89 d3                	mov    %edx,%ebx
  7d:	29 c3                	sub    %eax,%ebx
  7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  82:	89 04 24             	mov    %eax,(%esp)
  85:	e8 64 03 00 00       	call   3ee <strlen>
  8a:	05 14 10 00 00       	add    $0x1014,%eax
  8f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  93:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  9a:	00 
  9b:	89 04 24             	mov    %eax,(%esp)
  9e:	e8 70 03 00 00       	call   413 <memset>
  return buf;
  a3:	b8 14 10 00 00       	mov    $0x1014,%eax
}
  a8:	83 c4 24             	add    $0x24,%esp
  ab:	5b                   	pop    %ebx
  ac:	5d                   	pop    %ebp
  ad:	c3                   	ret    

000000ae <ls>:

void
ls(char *path)
{
  ae:	55                   	push   %ebp
  af:	89 e5                	mov    %esp,%ebp
  b1:	57                   	push   %edi
  b2:	56                   	push   %esi
  b3:	53                   	push   %ebx
  b4:	81 ec 5c 02 00 00    	sub    $0x25c,%esp
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;
  
  if((fd = open(path, 0)) < 0){
  ba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  c1:	00 
  c2:	8b 45 08             	mov    0x8(%ebp),%eax
  c5:	89 04 24             	mov    %eax,(%esp)
  c8:	e8 2b 05 00 00       	call   5f8 <open>
  cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  d4:	79 20                	jns    f6 <ls+0x48>
    printf(2, "ls: cannot open %s\n", path);
  d6:	8b 45 08             	mov    0x8(%ebp),%eax
  d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  dd:	c7 44 24 04 3c 0c 00 	movl   $0xc3c,0x4(%esp)
  e4:	00 
  e5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  ec:	e8 7e 06 00 00       	call   76f <printf>
    return;
  f1:	e9 01 02 00 00       	jmp    2f7 <ls+0x249>
  }
  
  if(fstat(fd, &st) < 0){
  f6:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
  fc:	89 44 24 04          	mov    %eax,0x4(%esp)
 100:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 103:	89 04 24             	mov    %eax,(%esp)
 106:	e8 05 05 00 00       	call   610 <fstat>
 10b:	85 c0                	test   %eax,%eax
 10d:	79 2b                	jns    13a <ls+0x8c>
    printf(2, "ls: cannot stat %s\n", path);
 10f:	8b 45 08             	mov    0x8(%ebp),%eax
 112:	89 44 24 08          	mov    %eax,0x8(%esp)
 116:	c7 44 24 04 50 0c 00 	movl   $0xc50,0x4(%esp)
 11d:	00 
 11e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 125:	e8 45 06 00 00       	call   76f <printf>
    close(fd);
 12a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 12d:	89 04 24             	mov    %eax,(%esp)
 130:	e8 ab 04 00 00       	call   5e0 <close>
    return;
 135:	e9 bd 01 00 00       	jmp    2f7 <ls+0x249>
  }
  
  switch(st.type){
 13a:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 141:	98                   	cwtl   
 142:	83 f8 01             	cmp    $0x1,%eax
 145:	74 53                	je     19a <ls+0xec>
 147:	83 f8 02             	cmp    $0x2,%eax
 14a:	0f 85 9c 01 00 00    	jne    2ec <ls+0x23e>
  case T_FILE:
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
 150:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 156:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 15c:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 163:	0f bf d8             	movswl %ax,%ebx
 166:	8b 45 08             	mov    0x8(%ebp),%eax
 169:	89 04 24             	mov    %eax,(%esp)
 16c:	e8 8f fe ff ff       	call   0 <fmtname>
 171:	89 7c 24 14          	mov    %edi,0x14(%esp)
 175:	89 74 24 10          	mov    %esi,0x10(%esp)
 179:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 17d:	89 44 24 08          	mov    %eax,0x8(%esp)
 181:	c7 44 24 04 64 0c 00 	movl   $0xc64,0x4(%esp)
 188:	00 
 189:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 190:	e8 da 05 00 00       	call   76f <printf>
    break;
 195:	e9 52 01 00 00       	jmp    2ec <ls+0x23e>
  
  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 19a:	8b 45 08             	mov    0x8(%ebp),%eax
 19d:	89 04 24             	mov    %eax,(%esp)
 1a0:	e8 49 02 00 00       	call   3ee <strlen>
 1a5:	83 c0 10             	add    $0x10,%eax
 1a8:	3d 00 02 00 00       	cmp    $0x200,%eax
 1ad:	76 19                	jbe    1c8 <ls+0x11a>
      printf(1, "ls: path too long\n");
 1af:	c7 44 24 04 71 0c 00 	movl   $0xc71,0x4(%esp)
 1b6:	00 
 1b7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1be:	e8 ac 05 00 00       	call   76f <printf>
      break;
 1c3:	e9 24 01 00 00       	jmp    2ec <ls+0x23e>
    }
    strcpy(buf, path);
 1c8:	8b 45 08             	mov    0x8(%ebp),%eax
 1cb:	89 44 24 04          	mov    %eax,0x4(%esp)
 1cf:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1d5:	89 04 24             	mov    %eax,(%esp)
 1d8:	e8 9c 01 00 00       	call   379 <strcpy>
    p = buf+strlen(buf);
 1dd:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1e3:	89 04 24             	mov    %eax,(%esp)
 1e6:	e8 03 02 00 00       	call   3ee <strlen>
 1eb:	8d 95 e0 fd ff ff    	lea    -0x220(%ebp),%edx
 1f1:	01 d0                	add    %edx,%eax
 1f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    *p++ = '/';
 1f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
 1f9:	c6 00 2f             	movb   $0x2f,(%eax)
 1fc:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 200:	e9 c0 00 00 00       	jmp    2c5 <ls+0x217>
      if(de.inum == 0)
 205:	0f b7 85 d0 fd ff ff 	movzwl -0x230(%ebp),%eax
 20c:	66 85 c0             	test   %ax,%ax
 20f:	0f 84 af 00 00 00    	je     2c4 <ls+0x216>
        continue;
      memmove(p, de.name, DIRSIZ);
 215:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
 21c:	00 
 21d:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 223:	83 c0 02             	add    $0x2,%eax
 226:	89 44 24 04          	mov    %eax,0x4(%esp)
 22a:	8b 45 e0             	mov    -0x20(%ebp),%eax
 22d:	89 04 24             	mov    %eax,(%esp)
 230:	e8 3d 03 00 00       	call   572 <memmove>
      p[DIRSIZ] = 0;
 235:	8b 45 e0             	mov    -0x20(%ebp),%eax
 238:	83 c0 0e             	add    $0xe,%eax
 23b:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
 23e:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
 244:	89 44 24 04          	mov    %eax,0x4(%esp)
 248:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 24e:	89 04 24             	mov    %eax,(%esp)
 251:	e8 83 02 00 00       	call   4d9 <stat>
 256:	85 c0                	test   %eax,%eax
 258:	79 20                	jns    27a <ls+0x1cc>
        printf(1, "ls: cannot stat %s\n", buf);
 25a:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 260:	89 44 24 08          	mov    %eax,0x8(%esp)
 264:	c7 44 24 04 50 0c 00 	movl   $0xc50,0x4(%esp)
 26b:	00 
 26c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 273:	e8 f7 04 00 00       	call   76f <printf>
        continue;
 278:	eb 4b                	jmp    2c5 <ls+0x217>
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 27a:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 280:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 286:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 28d:	0f bf d8             	movswl %ax,%ebx
 290:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 296:	89 04 24             	mov    %eax,(%esp)
 299:	e8 62 fd ff ff       	call   0 <fmtname>
 29e:	89 7c 24 14          	mov    %edi,0x14(%esp)
 2a2:	89 74 24 10          	mov    %esi,0x10(%esp)
 2a6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 2aa:	89 44 24 08          	mov    %eax,0x8(%esp)
 2ae:	c7 44 24 04 64 0c 00 	movl   $0xc64,0x4(%esp)
 2b5:	00 
 2b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2bd:	e8 ad 04 00 00       	call   76f <printf>
 2c2:	eb 01                	jmp    2c5 <ls+0x217>
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
      if(de.inum == 0)
        continue;
 2c4:	90                   	nop
      break;
    }
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 2c5:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 2cc:	00 
 2cd:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 2d3:	89 44 24 04          	mov    %eax,0x4(%esp)
 2d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2da:	89 04 24             	mov    %eax,(%esp)
 2dd:	e8 ee 02 00 00       	call   5d0 <read>
 2e2:	83 f8 10             	cmp    $0x10,%eax
 2e5:	0f 84 1a ff ff ff    	je     205 <ls+0x157>
        printf(1, "ls: cannot stat %s\n", buf);
        continue;
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
 2eb:	90                   	nop
  }
  close(fd);
 2ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2ef:	89 04 24             	mov    %eax,(%esp)
 2f2:	e8 e9 02 00 00       	call   5e0 <close>
}
 2f7:	81 c4 5c 02 00 00    	add    $0x25c,%esp
 2fd:	5b                   	pop    %ebx
 2fe:	5e                   	pop    %esi
 2ff:	5f                   	pop    %edi
 300:	5d                   	pop    %ebp
 301:	c3                   	ret    

00000302 <main>:

int
main(int argc, char *argv[])
{
 302:	55                   	push   %ebp
 303:	89 e5                	mov    %esp,%ebp
 305:	83 e4 f0             	and    $0xfffffff0,%esp
 308:	83 ec 20             	sub    $0x20,%esp
  int i;

  if(argc < 2){
 30b:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 30f:	7f 11                	jg     322 <main+0x20>
    ls(".");
 311:	c7 04 24 84 0c 00 00 	movl   $0xc84,(%esp)
 318:	e8 91 fd ff ff       	call   ae <ls>
    exit();
 31d:	e8 96 02 00 00       	call   5b8 <exit>
  }
  for(i=1; i<argc; i++)
 322:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
 329:	00 
 32a:	eb 19                	jmp    345 <main+0x43>
    ls(argv[i]);
 32c:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 330:	c1 e0 02             	shl    $0x2,%eax
 333:	03 45 0c             	add    0xc(%ebp),%eax
 336:	8b 00                	mov    (%eax),%eax
 338:	89 04 24             	mov    %eax,(%esp)
 33b:	e8 6e fd ff ff       	call   ae <ls>

  if(argc < 2){
    ls(".");
    exit();
  }
  for(i=1; i<argc; i++)
 340:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 345:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 349:	3b 45 08             	cmp    0x8(%ebp),%eax
 34c:	7c de                	jl     32c <main+0x2a>
    ls(argv[i]);
  exit();
 34e:	e8 65 02 00 00       	call   5b8 <exit>
 353:	90                   	nop

00000354 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 354:	55                   	push   %ebp
 355:	89 e5                	mov    %esp,%ebp
 357:	57                   	push   %edi
 358:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 359:	8b 4d 08             	mov    0x8(%ebp),%ecx
 35c:	8b 55 10             	mov    0x10(%ebp),%edx
 35f:	8b 45 0c             	mov    0xc(%ebp),%eax
 362:	89 cb                	mov    %ecx,%ebx
 364:	89 df                	mov    %ebx,%edi
 366:	89 d1                	mov    %edx,%ecx
 368:	fc                   	cld    
 369:	f3 aa                	rep stos %al,%es:(%edi)
 36b:	89 ca                	mov    %ecx,%edx
 36d:	89 fb                	mov    %edi,%ebx
 36f:	89 5d 08             	mov    %ebx,0x8(%ebp)
 372:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 375:	5b                   	pop    %ebx
 376:	5f                   	pop    %edi
 377:	5d                   	pop    %ebp
 378:	c3                   	ret    

00000379 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 379:	55                   	push   %ebp
 37a:	89 e5                	mov    %esp,%ebp
 37c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 37f:	8b 45 08             	mov    0x8(%ebp),%eax
 382:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 385:	90                   	nop
 386:	8b 45 0c             	mov    0xc(%ebp),%eax
 389:	0f b6 10             	movzbl (%eax),%edx
 38c:	8b 45 08             	mov    0x8(%ebp),%eax
 38f:	88 10                	mov    %dl,(%eax)
 391:	8b 45 08             	mov    0x8(%ebp),%eax
 394:	0f b6 00             	movzbl (%eax),%eax
 397:	84 c0                	test   %al,%al
 399:	0f 95 c0             	setne  %al
 39c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3a0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 3a4:	84 c0                	test   %al,%al
 3a6:	75 de                	jne    386 <strcpy+0xd>
    ;
  return os;
 3a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3ab:	c9                   	leave  
 3ac:	c3                   	ret    

000003ad <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3ad:	55                   	push   %ebp
 3ae:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3b0:	eb 08                	jmp    3ba <strcmp+0xd>
    p++, q++;
 3b2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3b6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 3ba:	8b 45 08             	mov    0x8(%ebp),%eax
 3bd:	0f b6 00             	movzbl (%eax),%eax
 3c0:	84 c0                	test   %al,%al
 3c2:	74 10                	je     3d4 <strcmp+0x27>
 3c4:	8b 45 08             	mov    0x8(%ebp),%eax
 3c7:	0f b6 10             	movzbl (%eax),%edx
 3ca:	8b 45 0c             	mov    0xc(%ebp),%eax
 3cd:	0f b6 00             	movzbl (%eax),%eax
 3d0:	38 c2                	cmp    %al,%dl
 3d2:	74 de                	je     3b2 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 3d4:	8b 45 08             	mov    0x8(%ebp),%eax
 3d7:	0f b6 00             	movzbl (%eax),%eax
 3da:	0f b6 d0             	movzbl %al,%edx
 3dd:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e0:	0f b6 00             	movzbl (%eax),%eax
 3e3:	0f b6 c0             	movzbl %al,%eax
 3e6:	89 d1                	mov    %edx,%ecx
 3e8:	29 c1                	sub    %eax,%ecx
 3ea:	89 c8                	mov    %ecx,%eax
}
 3ec:	5d                   	pop    %ebp
 3ed:	c3                   	ret    

000003ee <strlen>:

uint
strlen(char *s)
{
 3ee:	55                   	push   %ebp
 3ef:	89 e5                	mov    %esp,%ebp
 3f1:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3f4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3fb:	eb 04                	jmp    401 <strlen+0x13>
 3fd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 401:	8b 45 fc             	mov    -0x4(%ebp),%eax
 404:	03 45 08             	add    0x8(%ebp),%eax
 407:	0f b6 00             	movzbl (%eax),%eax
 40a:	84 c0                	test   %al,%al
 40c:	75 ef                	jne    3fd <strlen+0xf>
    ;
  return n;
 40e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 411:	c9                   	leave  
 412:	c3                   	ret    

00000413 <memset>:

void*
memset(void *dst, int c, uint n)
{
 413:	55                   	push   %ebp
 414:	89 e5                	mov    %esp,%ebp
 416:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 419:	8b 45 10             	mov    0x10(%ebp),%eax
 41c:	89 44 24 08          	mov    %eax,0x8(%esp)
 420:	8b 45 0c             	mov    0xc(%ebp),%eax
 423:	89 44 24 04          	mov    %eax,0x4(%esp)
 427:	8b 45 08             	mov    0x8(%ebp),%eax
 42a:	89 04 24             	mov    %eax,(%esp)
 42d:	e8 22 ff ff ff       	call   354 <stosb>
  return dst;
 432:	8b 45 08             	mov    0x8(%ebp),%eax
}
 435:	c9                   	leave  
 436:	c3                   	ret    

00000437 <strchr>:

char*
strchr(const char *s, char c)
{
 437:	55                   	push   %ebp
 438:	89 e5                	mov    %esp,%ebp
 43a:	83 ec 04             	sub    $0x4,%esp
 43d:	8b 45 0c             	mov    0xc(%ebp),%eax
 440:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 443:	eb 14                	jmp    459 <strchr+0x22>
    if(*s == c)
 445:	8b 45 08             	mov    0x8(%ebp),%eax
 448:	0f b6 00             	movzbl (%eax),%eax
 44b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 44e:	75 05                	jne    455 <strchr+0x1e>
      return (char*)s;
 450:	8b 45 08             	mov    0x8(%ebp),%eax
 453:	eb 13                	jmp    468 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 455:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 459:	8b 45 08             	mov    0x8(%ebp),%eax
 45c:	0f b6 00             	movzbl (%eax),%eax
 45f:	84 c0                	test   %al,%al
 461:	75 e2                	jne    445 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 463:	b8 00 00 00 00       	mov    $0x0,%eax
}
 468:	c9                   	leave  
 469:	c3                   	ret    

0000046a <gets>:

char*
gets(char *buf, int max)
{
 46a:	55                   	push   %ebp
 46b:	89 e5                	mov    %esp,%ebp
 46d:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 470:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 477:	eb 44                	jmp    4bd <gets+0x53>
    cc = read(0, &c, 1);
 479:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 480:	00 
 481:	8d 45 ef             	lea    -0x11(%ebp),%eax
 484:	89 44 24 04          	mov    %eax,0x4(%esp)
 488:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 48f:	e8 3c 01 00 00       	call   5d0 <read>
 494:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 497:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 49b:	7e 2d                	jle    4ca <gets+0x60>
      break;
    buf[i++] = c;
 49d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4a0:	03 45 08             	add    0x8(%ebp),%eax
 4a3:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 4a7:	88 10                	mov    %dl,(%eax)
 4a9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 4ad:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4b1:	3c 0a                	cmp    $0xa,%al
 4b3:	74 16                	je     4cb <gets+0x61>
 4b5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4b9:	3c 0d                	cmp    $0xd,%al
 4bb:	74 0e                	je     4cb <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c0:	83 c0 01             	add    $0x1,%eax
 4c3:	3b 45 0c             	cmp    0xc(%ebp),%eax
 4c6:	7c b1                	jl     479 <gets+0xf>
 4c8:	eb 01                	jmp    4cb <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 4ca:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 4cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ce:	03 45 08             	add    0x8(%ebp),%eax
 4d1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4d4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4d7:	c9                   	leave  
 4d8:	c3                   	ret    

000004d9 <stat>:

int
stat(char *n, struct stat *st)
{
 4d9:	55                   	push   %ebp
 4da:	89 e5                	mov    %esp,%ebp
 4dc:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4df:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 4e6:	00 
 4e7:	8b 45 08             	mov    0x8(%ebp),%eax
 4ea:	89 04 24             	mov    %eax,(%esp)
 4ed:	e8 06 01 00 00       	call   5f8 <open>
 4f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4f9:	79 07                	jns    502 <stat+0x29>
    return -1;
 4fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 500:	eb 23                	jmp    525 <stat+0x4c>
  r = fstat(fd, st);
 502:	8b 45 0c             	mov    0xc(%ebp),%eax
 505:	89 44 24 04          	mov    %eax,0x4(%esp)
 509:	8b 45 f4             	mov    -0xc(%ebp),%eax
 50c:	89 04 24             	mov    %eax,(%esp)
 50f:	e8 fc 00 00 00       	call   610 <fstat>
 514:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 517:	8b 45 f4             	mov    -0xc(%ebp),%eax
 51a:	89 04 24             	mov    %eax,(%esp)
 51d:	e8 be 00 00 00       	call   5e0 <close>
  return r;
 522:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 525:	c9                   	leave  
 526:	c3                   	ret    

00000527 <atoi>:

int
atoi(const char *s)
{
 527:	55                   	push   %ebp
 528:	89 e5                	mov    %esp,%ebp
 52a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 52d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 534:	eb 23                	jmp    559 <atoi+0x32>
    n = n*10 + *s++ - '0';
 536:	8b 55 fc             	mov    -0x4(%ebp),%edx
 539:	89 d0                	mov    %edx,%eax
 53b:	c1 e0 02             	shl    $0x2,%eax
 53e:	01 d0                	add    %edx,%eax
 540:	01 c0                	add    %eax,%eax
 542:	89 c2                	mov    %eax,%edx
 544:	8b 45 08             	mov    0x8(%ebp),%eax
 547:	0f b6 00             	movzbl (%eax),%eax
 54a:	0f be c0             	movsbl %al,%eax
 54d:	01 d0                	add    %edx,%eax
 54f:	83 e8 30             	sub    $0x30,%eax
 552:	89 45 fc             	mov    %eax,-0x4(%ebp)
 555:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 559:	8b 45 08             	mov    0x8(%ebp),%eax
 55c:	0f b6 00             	movzbl (%eax),%eax
 55f:	3c 2f                	cmp    $0x2f,%al
 561:	7e 0a                	jle    56d <atoi+0x46>
 563:	8b 45 08             	mov    0x8(%ebp),%eax
 566:	0f b6 00             	movzbl (%eax),%eax
 569:	3c 39                	cmp    $0x39,%al
 56b:	7e c9                	jle    536 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 56d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 570:	c9                   	leave  
 571:	c3                   	ret    

00000572 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 572:	55                   	push   %ebp
 573:	89 e5                	mov    %esp,%ebp
 575:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 578:	8b 45 08             	mov    0x8(%ebp),%eax
 57b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 57e:	8b 45 0c             	mov    0xc(%ebp),%eax
 581:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 584:	eb 13                	jmp    599 <memmove+0x27>
    *dst++ = *src++;
 586:	8b 45 f8             	mov    -0x8(%ebp),%eax
 589:	0f b6 10             	movzbl (%eax),%edx
 58c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 58f:	88 10                	mov    %dl,(%eax)
 591:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 595:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 599:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 59d:	0f 9f c0             	setg   %al
 5a0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 5a4:	84 c0                	test   %al,%al
 5a6:	75 de                	jne    586 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 5a8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5ab:	c9                   	leave  
 5ac:	c3                   	ret    
 5ad:	90                   	nop
 5ae:	90                   	nop
 5af:	90                   	nop

000005b0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5b0:	b8 01 00 00 00       	mov    $0x1,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret    

000005b8 <exit>:
SYSCALL(exit)
 5b8:	b8 02 00 00 00       	mov    $0x2,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret    

000005c0 <wait>:
SYSCALL(wait)
 5c0:	b8 03 00 00 00       	mov    $0x3,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret    

000005c8 <pipe>:
SYSCALL(pipe)
 5c8:	b8 04 00 00 00       	mov    $0x4,%eax
 5cd:	cd 40                	int    $0x40
 5cf:	c3                   	ret    

000005d0 <read>:
SYSCALL(read)
 5d0:	b8 05 00 00 00       	mov    $0x5,%eax
 5d5:	cd 40                	int    $0x40
 5d7:	c3                   	ret    

000005d8 <write>:
SYSCALL(write)
 5d8:	b8 10 00 00 00       	mov    $0x10,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret    

000005e0 <close>:
SYSCALL(close)
 5e0:	b8 15 00 00 00       	mov    $0x15,%eax
 5e5:	cd 40                	int    $0x40
 5e7:	c3                   	ret    

000005e8 <kill>:
SYSCALL(kill)
 5e8:	b8 06 00 00 00       	mov    $0x6,%eax
 5ed:	cd 40                	int    $0x40
 5ef:	c3                   	ret    

000005f0 <exec>:
SYSCALL(exec)
 5f0:	b8 07 00 00 00       	mov    $0x7,%eax
 5f5:	cd 40                	int    $0x40
 5f7:	c3                   	ret    

000005f8 <open>:
SYSCALL(open)
 5f8:	b8 0f 00 00 00       	mov    $0xf,%eax
 5fd:	cd 40                	int    $0x40
 5ff:	c3                   	ret    

00000600 <mknod>:
SYSCALL(mknod)
 600:	b8 11 00 00 00       	mov    $0x11,%eax
 605:	cd 40                	int    $0x40
 607:	c3                   	ret    

00000608 <unlink>:
SYSCALL(unlink)
 608:	b8 12 00 00 00       	mov    $0x12,%eax
 60d:	cd 40                	int    $0x40
 60f:	c3                   	ret    

00000610 <fstat>:
SYSCALL(fstat)
 610:	b8 08 00 00 00       	mov    $0x8,%eax
 615:	cd 40                	int    $0x40
 617:	c3                   	ret    

00000618 <link>:
SYSCALL(link)
 618:	b8 13 00 00 00       	mov    $0x13,%eax
 61d:	cd 40                	int    $0x40
 61f:	c3                   	ret    

00000620 <mkdir>:
SYSCALL(mkdir)
 620:	b8 14 00 00 00       	mov    $0x14,%eax
 625:	cd 40                	int    $0x40
 627:	c3                   	ret    

00000628 <chdir>:
SYSCALL(chdir)
 628:	b8 09 00 00 00       	mov    $0x9,%eax
 62d:	cd 40                	int    $0x40
 62f:	c3                   	ret    

00000630 <dup>:
SYSCALL(dup)
 630:	b8 0a 00 00 00       	mov    $0xa,%eax
 635:	cd 40                	int    $0x40
 637:	c3                   	ret    

00000638 <getpid>:
SYSCALL(getpid)
 638:	b8 0b 00 00 00       	mov    $0xb,%eax
 63d:	cd 40                	int    $0x40
 63f:	c3                   	ret    

00000640 <sbrk>:
SYSCALL(sbrk)
 640:	b8 0c 00 00 00       	mov    $0xc,%eax
 645:	cd 40                	int    $0x40
 647:	c3                   	ret    

00000648 <sleep>:
SYSCALL(sleep)
 648:	b8 0d 00 00 00       	mov    $0xd,%eax
 64d:	cd 40                	int    $0x40
 64f:	c3                   	ret    

00000650 <uptime>:
SYSCALL(uptime)
 650:	b8 0e 00 00 00       	mov    $0xe,%eax
 655:	cd 40                	int    $0x40
 657:	c3                   	ret    

00000658 <halt>:
SYSCALL(halt)
 658:	b8 16 00 00 00       	mov    $0x16,%eax
 65d:	cd 40                	int    $0x40
 65f:	c3                   	ret    

00000660 <clone>:

SYSCALL(clone)
 660:	b8 19 00 00 00       	mov    $0x19,%eax
 665:	cd 40                	int    $0x40
 667:	c3                   	ret    

00000668 <join>:
SYSCALL(join)
 668:	b8 1a 00 00 00       	mov    $0x1a,%eax
 66d:	cd 40                	int    $0x40
 66f:	c3                   	ret    

00000670 <texit>:
SYSCALL(texit)
 670:	b8 1b 00 00 00       	mov    $0x1b,%eax
 675:	cd 40                	int    $0x40
 677:	c3                   	ret    

00000678 <mutex_init>:
SYSCALL(mutex_init)
 678:	b8 1c 00 00 00       	mov    $0x1c,%eax
 67d:	cd 40                	int    $0x40
 67f:	c3                   	ret    

00000680 <mutex_destroy>:
SYSCALL(mutex_destroy)
 680:	b8 1d 00 00 00       	mov    $0x1d,%eax
 685:	cd 40                	int    $0x40
 687:	c3                   	ret    

00000688 <mutex_lock>:
SYSCALL(mutex_lock)
 688:	b8 1e 00 00 00       	mov    $0x1e,%eax
 68d:	cd 40                	int    $0x40
 68f:	c3                   	ret    

00000690 <mutex_unlock>:
 690:	b8 1f 00 00 00       	mov    $0x1f,%eax
 695:	cd 40                	int    $0x40
 697:	c3                   	ret    

00000698 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 698:	55                   	push   %ebp
 699:	89 e5                	mov    %esp,%ebp
 69b:	83 ec 28             	sub    $0x28,%esp
 69e:	8b 45 0c             	mov    0xc(%ebp),%eax
 6a1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 6a4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 6ab:	00 
 6ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
 6af:	89 44 24 04          	mov    %eax,0x4(%esp)
 6b3:	8b 45 08             	mov    0x8(%ebp),%eax
 6b6:	89 04 24             	mov    %eax,(%esp)
 6b9:	e8 1a ff ff ff       	call   5d8 <write>
}
 6be:	c9                   	leave  
 6bf:	c3                   	ret    

000006c0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6c0:	55                   	push   %ebp
 6c1:	89 e5                	mov    %esp,%ebp
 6c3:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6c6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6cd:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6d1:	74 17                	je     6ea <printint+0x2a>
 6d3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6d7:	79 11                	jns    6ea <printint+0x2a>
    neg = 1;
 6d9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6e0:	8b 45 0c             	mov    0xc(%ebp),%eax
 6e3:	f7 d8                	neg    %eax
 6e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6e8:	eb 06                	jmp    6f0 <printint+0x30>
  } else {
    x = xx;
 6ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 6ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6fd:	ba 00 00 00 00       	mov    $0x0,%edx
 702:	f7 f1                	div    %ecx
 704:	89 d0                	mov    %edx,%eax
 706:	0f b6 90 00 10 00 00 	movzbl 0x1000(%eax),%edx
 70d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 710:	03 45 f4             	add    -0xc(%ebp),%eax
 713:	88 10                	mov    %dl,(%eax)
 715:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 719:	8b 55 10             	mov    0x10(%ebp),%edx
 71c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 71f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 722:	ba 00 00 00 00       	mov    $0x0,%edx
 727:	f7 75 d4             	divl   -0x2c(%ebp)
 72a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 72d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 731:	75 c4                	jne    6f7 <printint+0x37>
  if(neg)
 733:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 737:	74 2a                	je     763 <printint+0xa3>
    buf[i++] = '-';
 739:	8d 45 dc             	lea    -0x24(%ebp),%eax
 73c:	03 45 f4             	add    -0xc(%ebp),%eax
 73f:	c6 00 2d             	movb   $0x2d,(%eax)
 742:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 746:	eb 1b                	jmp    763 <printint+0xa3>
    putc(fd, buf[i]);
 748:	8d 45 dc             	lea    -0x24(%ebp),%eax
 74b:	03 45 f4             	add    -0xc(%ebp),%eax
 74e:	0f b6 00             	movzbl (%eax),%eax
 751:	0f be c0             	movsbl %al,%eax
 754:	89 44 24 04          	mov    %eax,0x4(%esp)
 758:	8b 45 08             	mov    0x8(%ebp),%eax
 75b:	89 04 24             	mov    %eax,(%esp)
 75e:	e8 35 ff ff ff       	call   698 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 763:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 767:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 76b:	79 db                	jns    748 <printint+0x88>
    putc(fd, buf[i]);
}
 76d:	c9                   	leave  
 76e:	c3                   	ret    

0000076f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 76f:	55                   	push   %ebp
 770:	89 e5                	mov    %esp,%ebp
 772:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 775:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 77c:	8d 45 0c             	lea    0xc(%ebp),%eax
 77f:	83 c0 04             	add    $0x4,%eax
 782:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 785:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 78c:	e9 7d 01 00 00       	jmp    90e <printf+0x19f>
    c = fmt[i] & 0xff;
 791:	8b 55 0c             	mov    0xc(%ebp),%edx
 794:	8b 45 f0             	mov    -0x10(%ebp),%eax
 797:	01 d0                	add    %edx,%eax
 799:	0f b6 00             	movzbl (%eax),%eax
 79c:	0f be c0             	movsbl %al,%eax
 79f:	25 ff 00 00 00       	and    $0xff,%eax
 7a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 7a7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7ab:	75 2c                	jne    7d9 <printf+0x6a>
      if(c == '%'){
 7ad:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7b1:	75 0c                	jne    7bf <printf+0x50>
        state = '%';
 7b3:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 7ba:	e9 4b 01 00 00       	jmp    90a <printf+0x19b>
      } else {
        putc(fd, c);
 7bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7c2:	0f be c0             	movsbl %al,%eax
 7c5:	89 44 24 04          	mov    %eax,0x4(%esp)
 7c9:	8b 45 08             	mov    0x8(%ebp),%eax
 7cc:	89 04 24             	mov    %eax,(%esp)
 7cf:	e8 c4 fe ff ff       	call   698 <putc>
 7d4:	e9 31 01 00 00       	jmp    90a <printf+0x19b>
      }
    } else if(state == '%'){
 7d9:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7dd:	0f 85 27 01 00 00    	jne    90a <printf+0x19b>
      if(c == 'd'){
 7e3:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7e7:	75 2d                	jne    816 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 7e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7ec:	8b 00                	mov    (%eax),%eax
 7ee:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 7f5:	00 
 7f6:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 7fd:	00 
 7fe:	89 44 24 04          	mov    %eax,0x4(%esp)
 802:	8b 45 08             	mov    0x8(%ebp),%eax
 805:	89 04 24             	mov    %eax,(%esp)
 808:	e8 b3 fe ff ff       	call   6c0 <printint>
        ap++;
 80d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 811:	e9 ed 00 00 00       	jmp    903 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 816:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 81a:	74 06                	je     822 <printf+0xb3>
 81c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 820:	75 2d                	jne    84f <printf+0xe0>
        printint(fd, *ap, 16, 0);
 822:	8b 45 e8             	mov    -0x18(%ebp),%eax
 825:	8b 00                	mov    (%eax),%eax
 827:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 82e:	00 
 82f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 836:	00 
 837:	89 44 24 04          	mov    %eax,0x4(%esp)
 83b:	8b 45 08             	mov    0x8(%ebp),%eax
 83e:	89 04 24             	mov    %eax,(%esp)
 841:	e8 7a fe ff ff       	call   6c0 <printint>
        ap++;
 846:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 84a:	e9 b4 00 00 00       	jmp    903 <printf+0x194>
      } else if(c == 's'){
 84f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 853:	75 46                	jne    89b <printf+0x12c>
        s = (char*)*ap;
 855:	8b 45 e8             	mov    -0x18(%ebp),%eax
 858:	8b 00                	mov    (%eax),%eax
 85a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 85d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 861:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 865:	75 27                	jne    88e <printf+0x11f>
          s = "(null)";
 867:	c7 45 f4 86 0c 00 00 	movl   $0xc86,-0xc(%ebp)
        while(*s != 0){
 86e:	eb 1e                	jmp    88e <printf+0x11f>
          putc(fd, *s);
 870:	8b 45 f4             	mov    -0xc(%ebp),%eax
 873:	0f b6 00             	movzbl (%eax),%eax
 876:	0f be c0             	movsbl %al,%eax
 879:	89 44 24 04          	mov    %eax,0x4(%esp)
 87d:	8b 45 08             	mov    0x8(%ebp),%eax
 880:	89 04 24             	mov    %eax,(%esp)
 883:	e8 10 fe ff ff       	call   698 <putc>
          s++;
 888:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 88c:	eb 01                	jmp    88f <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 88e:	90                   	nop
 88f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 892:	0f b6 00             	movzbl (%eax),%eax
 895:	84 c0                	test   %al,%al
 897:	75 d7                	jne    870 <printf+0x101>
 899:	eb 68                	jmp    903 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 89b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 89f:	75 1d                	jne    8be <printf+0x14f>
        putc(fd, *ap);
 8a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8a4:	8b 00                	mov    (%eax),%eax
 8a6:	0f be c0             	movsbl %al,%eax
 8a9:	89 44 24 04          	mov    %eax,0x4(%esp)
 8ad:	8b 45 08             	mov    0x8(%ebp),%eax
 8b0:	89 04 24             	mov    %eax,(%esp)
 8b3:	e8 e0 fd ff ff       	call   698 <putc>
        ap++;
 8b8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8bc:	eb 45                	jmp    903 <printf+0x194>
      } else if(c == '%'){
 8be:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8c2:	75 17                	jne    8db <printf+0x16c>
        putc(fd, c);
 8c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8c7:	0f be c0             	movsbl %al,%eax
 8ca:	89 44 24 04          	mov    %eax,0x4(%esp)
 8ce:	8b 45 08             	mov    0x8(%ebp),%eax
 8d1:	89 04 24             	mov    %eax,(%esp)
 8d4:	e8 bf fd ff ff       	call   698 <putc>
 8d9:	eb 28                	jmp    903 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8db:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 8e2:	00 
 8e3:	8b 45 08             	mov    0x8(%ebp),%eax
 8e6:	89 04 24             	mov    %eax,(%esp)
 8e9:	e8 aa fd ff ff       	call   698 <putc>
        putc(fd, c);
 8ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8f1:	0f be c0             	movsbl %al,%eax
 8f4:	89 44 24 04          	mov    %eax,0x4(%esp)
 8f8:	8b 45 08             	mov    0x8(%ebp),%eax
 8fb:	89 04 24             	mov    %eax,(%esp)
 8fe:	e8 95 fd ff ff       	call   698 <putc>
      }
      state = 0;
 903:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 90a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 90e:	8b 55 0c             	mov    0xc(%ebp),%edx
 911:	8b 45 f0             	mov    -0x10(%ebp),%eax
 914:	01 d0                	add    %edx,%eax
 916:	0f b6 00             	movzbl (%eax),%eax
 919:	84 c0                	test   %al,%al
 91b:	0f 85 70 fe ff ff    	jne    791 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 921:	c9                   	leave  
 922:	c3                   	ret    
 923:	90                   	nop

00000924 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 924:	55                   	push   %ebp
 925:	89 e5                	mov    %esp,%ebp
 927:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 92a:	8b 45 08             	mov    0x8(%ebp),%eax
 92d:	83 e8 08             	sub    $0x8,%eax
 930:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 933:	a1 2c 10 00 00       	mov    0x102c,%eax
 938:	89 45 fc             	mov    %eax,-0x4(%ebp)
 93b:	eb 24                	jmp    961 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 93d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 940:	8b 00                	mov    (%eax),%eax
 942:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 945:	77 12                	ja     959 <free+0x35>
 947:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 94d:	77 24                	ja     973 <free+0x4f>
 94f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 952:	8b 00                	mov    (%eax),%eax
 954:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 957:	77 1a                	ja     973 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 959:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95c:	8b 00                	mov    (%eax),%eax
 95e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 961:	8b 45 f8             	mov    -0x8(%ebp),%eax
 964:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 967:	76 d4                	jbe    93d <free+0x19>
 969:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96c:	8b 00                	mov    (%eax),%eax
 96e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 971:	76 ca                	jbe    93d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 973:	8b 45 f8             	mov    -0x8(%ebp),%eax
 976:	8b 40 04             	mov    0x4(%eax),%eax
 979:	c1 e0 03             	shl    $0x3,%eax
 97c:	89 c2                	mov    %eax,%edx
 97e:	03 55 f8             	add    -0x8(%ebp),%edx
 981:	8b 45 fc             	mov    -0x4(%ebp),%eax
 984:	8b 00                	mov    (%eax),%eax
 986:	39 c2                	cmp    %eax,%edx
 988:	75 24                	jne    9ae <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 98a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 98d:	8b 50 04             	mov    0x4(%eax),%edx
 990:	8b 45 fc             	mov    -0x4(%ebp),%eax
 993:	8b 00                	mov    (%eax),%eax
 995:	8b 40 04             	mov    0x4(%eax),%eax
 998:	01 c2                	add    %eax,%edx
 99a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 99d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 9a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a3:	8b 00                	mov    (%eax),%eax
 9a5:	8b 10                	mov    (%eax),%edx
 9a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9aa:	89 10                	mov    %edx,(%eax)
 9ac:	eb 0a                	jmp    9b8 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 9ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b1:	8b 10                	mov    (%eax),%edx
 9b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b6:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 9b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9bb:	8b 40 04             	mov    0x4(%eax),%eax
 9be:	c1 e0 03             	shl    $0x3,%eax
 9c1:	03 45 fc             	add    -0x4(%ebp),%eax
 9c4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9c7:	75 20                	jne    9e9 <free+0xc5>
    p->s.size += bp->s.size;
 9c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9cc:	8b 50 04             	mov    0x4(%eax),%edx
 9cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9d2:	8b 40 04             	mov    0x4(%eax),%eax
 9d5:	01 c2                	add    %eax,%edx
 9d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9da:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9e0:	8b 10                	mov    (%eax),%edx
 9e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e5:	89 10                	mov    %edx,(%eax)
 9e7:	eb 08                	jmp    9f1 <free+0xcd>
  } else
    p->s.ptr = bp;
 9e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ec:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9ef:	89 10                	mov    %edx,(%eax)
  freep = p;
 9f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f4:	a3 2c 10 00 00       	mov    %eax,0x102c
}
 9f9:	c9                   	leave  
 9fa:	c3                   	ret    

000009fb <morecore>:

static Header*
morecore(uint nu)
{
 9fb:	55                   	push   %ebp
 9fc:	89 e5                	mov    %esp,%ebp
 9fe:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a01:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a08:	77 07                	ja     a11 <morecore+0x16>
    nu = 4096;
 a0a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a11:	8b 45 08             	mov    0x8(%ebp),%eax
 a14:	c1 e0 03             	shl    $0x3,%eax
 a17:	89 04 24             	mov    %eax,(%esp)
 a1a:	e8 21 fc ff ff       	call   640 <sbrk>
 a1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a22:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a26:	75 07                	jne    a2f <morecore+0x34>
    return 0;
 a28:	b8 00 00 00 00       	mov    $0x0,%eax
 a2d:	eb 22                	jmp    a51 <morecore+0x56>
  hp = (Header*)p;
 a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a32:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a35:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a38:	8b 55 08             	mov    0x8(%ebp),%edx
 a3b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a41:	83 c0 08             	add    $0x8,%eax
 a44:	89 04 24             	mov    %eax,(%esp)
 a47:	e8 d8 fe ff ff       	call   924 <free>
  return freep;
 a4c:	a1 2c 10 00 00       	mov    0x102c,%eax
}
 a51:	c9                   	leave  
 a52:	c3                   	ret    

00000a53 <malloc>:

void*
malloc(uint nbytes)
{
 a53:	55                   	push   %ebp
 a54:	89 e5                	mov    %esp,%ebp
 a56:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a59:	8b 45 08             	mov    0x8(%ebp),%eax
 a5c:	83 c0 07             	add    $0x7,%eax
 a5f:	c1 e8 03             	shr    $0x3,%eax
 a62:	83 c0 01             	add    $0x1,%eax
 a65:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a68:	a1 2c 10 00 00       	mov    0x102c,%eax
 a6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a70:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a74:	75 23                	jne    a99 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a76:	c7 45 f0 24 10 00 00 	movl   $0x1024,-0x10(%ebp)
 a7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a80:	a3 2c 10 00 00       	mov    %eax,0x102c
 a85:	a1 2c 10 00 00       	mov    0x102c,%eax
 a8a:	a3 24 10 00 00       	mov    %eax,0x1024
    base.s.size = 0;
 a8f:	c7 05 28 10 00 00 00 	movl   $0x0,0x1028
 a96:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a99:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a9c:	8b 00                	mov    (%eax),%eax
 a9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa4:	8b 40 04             	mov    0x4(%eax),%eax
 aa7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 aaa:	72 4d                	jb     af9 <malloc+0xa6>
      if(p->s.size == nunits)
 aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aaf:	8b 40 04             	mov    0x4(%eax),%eax
 ab2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 ab5:	75 0c                	jne    ac3 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aba:	8b 10                	mov    (%eax),%edx
 abc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 abf:	89 10                	mov    %edx,(%eax)
 ac1:	eb 26                	jmp    ae9 <malloc+0x96>
      else {
        p->s.size -= nunits;
 ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac6:	8b 40 04             	mov    0x4(%eax),%eax
 ac9:	89 c2                	mov    %eax,%edx
 acb:	2b 55 ec             	sub    -0x14(%ebp),%edx
 ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad7:	8b 40 04             	mov    0x4(%eax),%eax
 ada:	c1 e0 03             	shl    $0x3,%eax
 add:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 ae6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 ae9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aec:	a3 2c 10 00 00       	mov    %eax,0x102c
      return (void*)(p + 1);
 af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af4:	83 c0 08             	add    $0x8,%eax
 af7:	eb 38                	jmp    b31 <malloc+0xde>
    }
    if(p == freep)
 af9:	a1 2c 10 00 00       	mov    0x102c,%eax
 afe:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b01:	75 1b                	jne    b1e <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 b03:	8b 45 ec             	mov    -0x14(%ebp),%eax
 b06:	89 04 24             	mov    %eax,(%esp)
 b09:	e8 ed fe ff ff       	call   9fb <morecore>
 b0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b11:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b15:	75 07                	jne    b1e <malloc+0xcb>
        return 0;
 b17:	b8 00 00 00 00       	mov    $0x0,%eax
 b1c:	eb 13                	jmp    b31 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b21:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b27:	8b 00                	mov    (%eax),%eax
 b29:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 b2c:	e9 70 ff ff ff       	jmp    aa1 <malloc+0x4e>
}
 b31:	c9                   	leave  
 b32:	c3                   	ret    
 b33:	90                   	nop

00000b34 <pthread_create>:
	clone's 3rd argument, *stek, should be allocated here?
*/

#define PAGESIZE (4096)  //Maybe 4092??

int pthread_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine) (void*), void *arg){
 b34:	55                   	push   %ebp
 b35:	89 e5                	mov    %esp,%ebp
 b37:	83 ec 28             	sub    $0x28,%esp

	void *mystek = malloc((uint)PAGESIZE*2); //Why do we need the *2?
 b3a:	c7 04 24 00 20 00 00 	movl   $0x2000,(%esp)
 b41:	e8 0d ff ff ff       	call   a53 <malloc>
 b46:	89 45 f4             	mov    %eax,-0xc(%ebp)
//zzddhhtjzz/xv6/blob/master
	if((uint)mystek % PAGESIZE){
 b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b4c:	25 ff 0f 00 00       	and    $0xfff,%eax
 b51:	85 c0                	test   %eax,%eax
 b53:	74 15                	je     b6a <pthread_create+0x36>
		mystek += 4096 - ((uint)mystek % PAGESIZE);
 b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b58:	89 c2                	mov    %eax,%edx
 b5a:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
 b60:	b8 00 10 00 00       	mov    $0x1000,%eax
 b65:	29 d0                	sub    %edx,%eax
 b67:	01 45 f4             	add    %eax,-0xc(%ebp)
	}
	thread->pid = clone(start_routine, arg, mystek);
 b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b6d:	89 44 24 08          	mov    %eax,0x8(%esp)
 b71:	8b 45 14             	mov    0x14(%ebp),%eax
 b74:	89 44 24 04          	mov    %eax,0x4(%esp)
 b78:	8b 45 10             	mov    0x10(%ebp),%eax
 b7b:	89 04 24             	mov    %eax,(%esp)
 b7e:	e8 dd fa ff ff       	call   660 <clone>
 b83:	8b 55 08             	mov    0x8(%ebp),%edx
 b86:	89 02                	mov    %eax,(%edx)
	return thread->pid;
 b88:	8b 45 08             	mov    0x8(%ebp),%eax
 b8b:	8b 00                	mov    (%eax),%eax
}
 b8d:	c9                   	leave  
 b8e:	c3                   	ret    

00000b8f <pthread_join>:

int pthread_join(pthread_t thread, void **retval){
 b8f:	55                   	push   %ebp
 b90:	89 e5                	mov    %esp,%ebp
 b92:	83 ec 28             	sub    $0x28,%esp

	void *stek;

	join((int)thread.pid, &stek, (void*)retval);
 b95:	8b 45 08             	mov    0x8(%ebp),%eax
 b98:	8b 55 0c             	mov    0xc(%ebp),%edx
 b9b:	89 54 24 08          	mov    %edx,0x8(%esp)
 b9f:	8d 55 f4             	lea    -0xc(%ebp),%edx
 ba2:	89 54 24 04          	mov    %edx,0x4(%esp)
 ba6:	89 04 24             	mov    %eax,(%esp)
 ba9:	e8 ba fa ff ff       	call   668 <join>

	free(stek);
 bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bb1:	89 04 24             	mov    %eax,(%esp)
 bb4:	e8 6b fd ff ff       	call   924 <free>

	return 0;
 bb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
 bbe:	c9                   	leave  
 bbf:	c3                   	ret    

00000bc0 <pthread_exit>:

int pthread_exit(void *retval){
 bc0:	55                   	push   %ebp
 bc1:	89 e5                	mov    %esp,%ebp
 bc3:	83 ec 18             	sub    $0x18,%esp

	texit(retval);
 bc6:	8b 45 08             	mov    0x8(%ebp),%eax
 bc9:	89 04 24             	mov    %eax,(%esp)
 bcc:	e8 9f fa ff ff       	call   670 <texit>

	return 0;
 bd1:	b8 00 00 00 00       	mov    $0x0,%eax
}
 bd6:	c9                   	leave  
 bd7:	c3                   	ret    

00000bd8 <pthread_mutex_init>:


int pthread_mutex_init(pthread_mutex_t *mutex, const pthread_mutex_attr_t *attr){
 bd8:	55                   	push   %ebp
 bd9:	89 e5                	mov    %esp,%ebp
 bdb:	83 ec 18             	sub    $0x18,%esp

	int mid = mutex_init();
 bde:	e8 95 fa ff ff       	call   678 <mutex_init>
 be3:	89 45 f4             	mov    %eax,-0xc(%ebp)

	//returns the id of the initalized mutex
	return mid;
 be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
 be9:	c9                   	leave  
 bea:	c3                   	ret    

00000beb <pthread_mutex_destroy>:


int pthread_mutex_destroy(pthread_mutex_t *mutex){
 beb:	55                   	push   %ebp
 bec:	89 e5                	mov    %esp,%ebp
 bee:	83 ec 18             	sub    $0x18,%esp

	mutex_destroy(mutex->mid);
 bf1:	8b 45 08             	mov    0x8(%ebp),%eax
 bf4:	8b 40 04             	mov    0x4(%eax),%eax
 bf7:	89 04 24             	mov    %eax,(%esp)
 bfa:	e8 81 fa ff ff       	call   680 <mutex_destroy>
	return 0;
 bff:	b8 00 00 00 00       	mov    $0x0,%eax
}
 c04:	c9                   	leave  
 c05:	c3                   	ret    

00000c06 <pthread_mutex_lock>:


int pthread_mutex_lock(pthread_mutex_t *mutex){
 c06:	55                   	push   %ebp
 c07:	89 e5                	mov    %esp,%ebp
 c09:	83 ec 18             	sub    $0x18,%esp

	mutex_lock(mutex->mid);
 c0c:	8b 45 08             	mov    0x8(%ebp),%eax
 c0f:	8b 40 04             	mov    0x4(%eax),%eax
 c12:	89 04 24             	mov    %eax,(%esp)
 c15:	e8 6e fa ff ff       	call   688 <mutex_lock>
	return 0;
 c1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 c1f:	c9                   	leave  
 c20:	c3                   	ret    

00000c21 <pthread_mutex_unlock>:


int pthread_mutex_unlock(pthread_mutex_t *mutex){
 c21:	55                   	push   %ebp
 c22:	89 e5                	mov    %esp,%ebp
 c24:	83 ec 18             	sub    $0x18,%esp

	mutex_unlock(mutex->mid);
 c27:	8b 45 08             	mov    0x8(%ebp),%eax
 c2a:	8b 40 04             	mov    0x4(%eax),%eax
 c2d:	89 04 24             	mov    %eax,(%esp)
 c30:	e8 5b fa ff ff       	call   690 <mutex_unlock>
	return 0;
 c35:	b8 00 00 00 00       	mov    $0x0,%eax
 c3a:	c9                   	leave  
 c3b:	c3                   	ret    
