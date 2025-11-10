
# Apache Hadoop 3.3.6 – Local Mode Setup in GitHub Codespaces

This project demonstrates how to **set up and run Apache Hadoop (v3.3.6)** in a **GitHub Codespaces environment** using **local (single-node) mode**.  
It includes Hadoop installation, configuration, basic file management, and execution of the **WordCount MapReduce** program — all within a lightweight Linux container.

---

## 🚀 Objectives

- Set up **Apache Hadoop 3.3.6** inside GitHub Codespaces.  
- Perform **file management operations**: create, add, retrieve, and delete files.  
- Execute the **WordCount MapReduce** example and verify its output.  

---

## ⚙️ Environment Setup

| Component | Details |
|------------|----------|
| **Hadoop Version** | 3.3.6 |
| **Mode** | Local (Single-node, no HDFS daemons) |
| **Platform** | GitHub Codespaces / Linux Container |
| **Java Version** | OpenJDK 11 |

### Environment Variables

```bash
export HADOOP_HOME=/opt/hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_LOG_DIR=~/hadoop-logs
mkdir -p ~/hadoop-logs
````

---

## 📂 HDFS / File Management Operations

### Step 1: Create Directories

```bash
mkdir -p ~/hadoop-local/input
```

### Step 2: Create Sample Input File

```bash
echo "Hello Hadoop World Hadoop" > ~/hadoop-local/input/wordcount.txt
echo "Hadoop is fun" >> ~/hadoop-local/input/wordcount.txt
```

### Step 3: Verify File Content

```bash
cat ~/hadoop-local/input/wordcount.txt
```

**Expected Output:**

```
Hello Hadoop World Hadoop
Hadoop is fun
```

---

## 🧮 Run MapReduce WordCount Program

### Command

```bash
$HADOOP_HOME/bin/hadoop jar \
$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar \
wordcount ~/hadoop-local/input ~/hadoop-local/output
```

**Explanation:**

* Reads input files from `~/hadoop-local/input`
* Counts the frequency of each word
* Writes results to `~/hadoop-local/output`

### View Output

```bash
cat ~/hadoop-local/output/part-r-00000
```

**Sample Output:**

```
Hadoop 3
Hello 1
World 1
fun 1
is 1
```

---

## 🧹 Clean Up

```bash
rm -rf ~/hadoop-local/input ~/hadoop-local/output
```

This removes previous files and prepares a clean workspace for the next run.

---

## ✅ Observations

* Hadoop ran successfully in **local mode** without requiring HDFS daemons.
* File creation, retrieval, and deletion worked correctly on the local filesystem.
* The **WordCount MapReduce program** executed successfully and produced accurate word counts.
* Running Hadoop inside **GitHub Codespaces** avoided SSH and permission issues commonly seen in local setups.

---

## 📘 References

* [Apache Hadoop Official Documentation](https://hadoop.apache.org/docs/stable/)
* [Hadoop: The Definitive Guide – Tom White](https://www.oreilly.com/library/view/hadoop-the-definitive/9781491901687/)
* [GitHub Codespaces Documentation](https://docs.github.com/en/codespaces)

---

Would you like me to add a **badge-style header** (e.g., Hadoop version, Java version, environment badges) at the top of the README to make it look even more professional on GitHub?
```
