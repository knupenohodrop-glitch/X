 Missing commit data on build:
```bash
	root@fee62c233d78:/data# history
    1  cd data/
    2  ld
    3  ls
    4  git status
    5  git status
    6  git add .
    7  git branch
    8  git commit
    9  git config --global user.email "you@example.com"
   10  git config --global user.name "Your Name"
   11  git status
   12  git commit
   13  git commit -m init
   14  gitvpushborigin
   15  git push origin
   16  git push --set-upstream origin st
   17  git push origin
   18  git status
   19  history
```

And problems with key confirm
```bash
The authenticity of host 'github.com (140.82.121.3)' can't be established.
ED25519 key fingerprint is SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Failed to add the host to the list of known hosts (/root/.ssh/known_hosts).
Enumerating objects: 153, done.
Counting objects: 100% (153/153), done.
Delta compression using up to 4 threads
Compressing objects: 100% (78/78), done.
Writing objects: 100% (78/78), 12.95 KiB | 884.00 KiB/s, done.
Total 78 (delta 37), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (37/37), completed with 37 local objects.
To github.com:knupenohodrop-glitch/X.git
   f51e3b8..de1c358  st -> st
root@fee62c233d78:/data# git push
The authenticity of host 'github.com (140.82.121.4)' can't be established.
ED25519 key fingerprint is SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Failed to add the host to the list of known hosts (/root/.ssh/known_hosts).
Enumerating objects: 1056, done.
Counting objects: 100% (1056/1056), done.
Delta compression using up to 4 threads
Compressing objects: 100% (982/982), done.
Writing objects: 100% (982/982), 95.67 KiB | 1.01 MiB/s, done.
Total 982 (delta 483), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (483/483), completed with 37 local objects.
To github.com:knupenohodrop-glitch/X.git
```

so it fails Automatic push....
not a problem now, but fix required...
