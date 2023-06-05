# g-flow
![Logo](/media/logo.png)

[ en ] [ [pt-BR](/README.md) ] 

---

[ [Intro](#intro) ] [ [Tool](#tool) ] [ [Branching Strategy](#branching-strategy) ] [ [Example Flows](#example-flows) ] [ [FAQ](#faq) ] [ [License](#license) ]

## Intro
g-flow is a complete and practical Gitflow implementation.

[Gitflow](https://nvie.com/posts/a-successful-git-branching-model/) is a well known and widely adopted branching strategy. 

There are, however, a few problems:

1. The tools created by the author himself, not only seem to be abandoned, but don't take in consideraton the existence of a hub (Github, Gitlab, Bitbucket, etc...) what spawn a myriad of forks, which in turn have their own problems;
1. The strategy itself and therefore the tools consider only two permanent branches, which not only doesn't match the reality of many repositories, but leaves room for improvement (more on that below).

### Branching Strategy
As mentioned before g-flow is a strategy based on [Gitflow](https://nvie.com/posts/a-successful-git-branching-model/), shown in the diagrams and concepts below.

Important points to be considered:

1. Only these branches are permanent: Development (dev), Homologation (homolog), Production (main) and Release branches;
1. Temporary branches are deleted after the launch of the release that contains them;
1. All work branches always come from Production;
1. The Production branch only receives updates from Hotfixes and Releases;
1. Releases are walways launched on Production and Homologation.

### Concepts

1. Development is the Bleeding Edge branch,where all issues are merged once approved.
1. Homologation is the Pre-Release branch and can temporarily become out of sync with the others depending on the Homologation process.
1. Release branches are permanent on purpose, so it's possible to do quick switches for regression, inspection, comparisons, etc...
1. At the conception of the project (time === 0), the initial branches (Development, Homologation and Production) are exactly equal and, in case of a pre-existing system, a mirror of the Client's Production branch;
1. Code Freeze is the period of time when it's absolutely forbidden to do merges in any branch.

### Tool

#### Important

1. As in any Open Source Software, the `g-flow.sh` tool is provided without warranties (see the [License](/LICENSE) file);
1. Please note that the tool will **always**:
* Switch to the Production branch and do a pull to certify that your production copy is synchronized;
* The immediate push of the created branch to remote.
3. Although I'm not an ignorant on the subject I'm not, by any stretch of imagination, a bash programmer and therefore many things in the tool can probably be improved. Soon I'll publish the guidelines to contribute to the project.
1. At the moment the tool was only tested on Linux (Fedora, but it probably works in any distribution that has a modern bash implementation running). Tests in other Linux distributions and other Operating Systems are **more than welcome**, but I can't guarantee implementations for difrerent Operating Systems.

#### Installation

Just clone this repository or download the [most recent release](https://github.com/galvao-eti/g-flow/releases).

Optionally (recommended) create a symbolic link to the tool:

```bash
sudo ln -s path_to_clone/bin/g-flow.sh /usr/local/bin/g-flow
```

#### Usage

Just run the tool with no arguments to display the usage help:

```bash
g-flow
```

#### Configuration

The tool runs with a default configuration, present in the [.g-flowrc.dist file](/.g-flowrc.dist).

To change any configuration copy this file as `.g-flowrc` in your project's root path. The file is always valid only for the project itself.

Don't use quotes in any configuration values and don't use characters except for letters, numbers, dashes ( - ) and underscores ( _ ).

### Example Flows:

#### Flow 0: Hotfix
![Flow 0](/media/diagram/Case0-Hotfix.png)
1. After identifying the bug, the Release Manager (RM) declares the beginning of the Code Freeze.
1. Dev creates the branch with the format hotfix/issue from Production and immediately creates it remotely, e.g.: 

With `g-flow.sh`:

 ```bash
 g-flow hfix 1903
 ```
  
Without `g-flow.sh`:

 ```bash
 git checkout -b hotfix/1903 main
 git push -u origin hotfix/1903
 ```
3. Dev works on it's branch, tests the fix locally, makes pushes to it's remote branch and notifies the RM:

```bash
 git add modified_files
 git commit -m "Commit Message"
 git push
 ```
4. The RM merges it into Production and Development.
4. Being declared that the bug is solved, the RM launches the Release from Production and merges it to all Homologation and Production branches.
4. Code Freeze ends.

#### Fluxo 1: Feature
![Flow 1](/media/diagram/Case1-Feature.png)
1. Dev creates the branch with the format feature/issue from Production and immediately creates it remotely, e.g.:
 
With `g-flow.sh`:

 ```bash
 g-flow feat 1901
 ```
  
Without `g-flow.sh`:

 ```bash
 git checkout -b feature/1901 main
 git push -u origin feature/1901
 ```
  2. Dev works on it’s branch, tests the feature locally, makes pushes to it’s remote branch:
```bash
 git add modified_files
 git commit -m "Commit Message"
 git push
 ```
3. After completing the work, Dev opens a PR to Development.
3. Code Review is performed.
3. If the PR is approved, the RM merges it into Development and Homologation and declares the beginning of the Code Freeze.
3. In Homologation the Business Logic tests are performed. If the work is homologated, it's merged in the Client's Homologation environment.
3. The Client then performs it's tests so the change is homologated.
3. If the client homologates it, the RM launches the Release from Homologation and and merges it to all Homologation and Production branches.
3. Code Freeze ends.
#### Flow 2: Epic Feature
![Flow 2](/media/diagram/Case2-Epic.png)
1. A branch with the name following the format epic/epic_name is created from Production.
1. Devs create feature branches with the name following the format feature/issue from the epic/epic_name branch and immediatelt create them remotely e.g.:  

With `g-flow.sh`:

 ```bash
 g-flow feat 1902 epic/nome_epic
 ```
Without `g-flow.sh`:
 
 ```bash
 git checkout -b feature/1902 epic/nome_epic
 git push -u origin feature/1902
 ```
  3. Devs work on their branches, test the feature locally and make pushes to their remote branch.
 ```bash
 git add modified_files
 git commit -m "Commit Message"
 git push
 ```
4. After completing the work, Dev opens a PR to the Epic's branch.
4. Code Review is performed.
4. If the PR is approved, the RM merges it into the Epic's branch.
4. Once the epic is finished and tested, Dev opens a PR to Development.
4. If the PR is approved, the RM merges it into Development and Homologation and declares the beginning of the Code Freeze.
4. In Homologation the Business Logic tests are performed. If the work is homologated, it's merged in the Client's Homologation environment.
4. The Client then performs it's tests so the change is homologated.
4. If the client homologates it, the RM launches the Release from Homologation and and merges it to all Homologation and Production branches.
4. Code Freeze ends.
#### Flow 3: Fix
![Flow 3](/media/diagram/Case3-Fix.png)
1. Dev creates the branch with the format fix/issue from Production and immediately creates it remotely, e.g.:
 
With `g-flow.sh`:

 ```bash
 g-flow fix 1901
 ```
  
Without `g-flow.sh`:

 ```bash
 git checkout -b fix/1901 main
 git push -u origin fix/1901
 ```
  2. Dev works on it’s branch, tests the fix locally, makes pushes to it’s remote branch:
```bash
 git add modified_files
 git commit -m "Commit Message"
 git push
 ```
3. After completing the work, Dev opens a PR to Development.
3. Code Review is performed.
3. If the PR is approved, the RM merges it into Development and Homologation and declares the beginning of the Code Freeze.
3. In Homologation the Business Logic tests are performed. If the work is homologated, it's merged in the Client's Homologation environment.
3. The Client then performs it's tests so the change is homologated.
3. If the client homologates it, the RM launches the Release from Homologation and and merges it to all Homologation and Production branches.
3. Code Freeze ends.

## FAQ

<details>
<summary>1. There are so many branch types. Why?</summary>
So that is possible to build metricsw (amount of fixes, features, etc... per release).
</details>
<details>
<summary>2. What's the difference between Hotfix and Fix?</summary>
The difference is procedural. Hotfix is a critical bug that is happening in Production and therefore must be fixed quickly, ignoring some steps that are performed in a "normal" Fix (Code Review, Source of the Release, etc...).
</details>
<details>
<summary>3. What's the reason for the Homologation branch to receive releases if the release comes from it (same case with hotfixes and the Production branch)?</summary>
In order to keep the Homologation and Production branches absolutely synchronized, including releases and versioning.
</details>
<details>
<summary>4. Versioning?</summary>
Yes. g-flow is aligned with the practice of [Semantic Verioning](https://semver.org/). The tool will include a "bump" script.
</details>

## License

Licensed as MIT 2023-* by [Galvão Desenvolvimento Ltda.](https://galvao.eti.br)

[Licença completa](/LICENSE)
