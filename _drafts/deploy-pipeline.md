---
title: Design Jenkins Deployment Pipeline for Multiple Projects
---

## Design Jenkins Deployment Pipeline for Multiple Projects

For current project, we have one code base for both backend and frontend components.

We have two jenkins jobs, one for rspec(backend) and one for karma(frontend), probally protractor sooner or latter.

How to design deployment stratragy?

I start googling around. 
I do have a straigthforward solution. Run the rspec first then run the karma,
setup downstream between these two. Once karma build success, run the deployment job. Done.

This solution is simple but not sufficent. Just something not feel right.

references
[jenkins fingerprint](https://wiki.jenkins-ci.org/display/JENKINS/Fingerprint)
[stackoverflow](http://stackoverflow.com/questions/9012310/how-do-i-make-a-jenkins-job-start-after-multiple-simultaneous-upstream-jobs-succ)
