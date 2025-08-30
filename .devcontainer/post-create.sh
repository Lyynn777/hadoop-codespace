#!/usr/bin/env bash
set -euo pipefail

HADOOP_VERSION=${HADOOP_VERSION:-3.3.6}
HADOOP_DIR=/opt/hadoop
HADOOP_HOME=${HADOOP_DIR}/hadoop-${HADOOP_VERSION}
TARBALL_NAME=hadoop-${HADOOP_VERSION}.tar.gz
REPO_ROOT="$(pwd)"

echo "Hadoop setup: version=${HADOOP_VERSION}, HADOOP_HOME=${HADOOP_HOME}"

if [ -f "${REPO_ROOT}/hadoop.tar" ]; then
  echo "Using local hadoop.tar..."
  sudo mkdir -p "${HADOOP_DIR}"
  sudo tar -xvf "${REPO_ROOT}/hadoop.tar" -C "${HADOOP_DIR}" --strip-components=1
else
  echo "Downloading Hadoop ${HADOOP_VERSION}..."
  wget -qO "/tmp/${TARBALL_NAME}" "https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/${TARBALL_NAME}"
  sudo mkdir -p "${HADOOP_DIR}"
  sudo tar -xzf "/tmp/${TARBALL_NAME}" -C "${HADOOP_DIR}" --strip-components=1
fi

sudo chown -R "$(id -u):$(id -g)" "${HADOOP_HOME}"

if ! grep -q "HADOOP_HOME=${HADOOP_HOME}" ~/.bashrc 2>/dev/null; then
  cat >> ~/.bashrc <<EOF

# Hadoop environment
export HADOOP_HOME=${HADOOP_HOME}
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin
EOF
fi

HADOOP_ENV_FILE="${HADOOP_HOME}/etc/hadoop/hadoop-env.sh"
if grep -q "JAVA_HOME" "${HADOOP_ENV_FILE}" 2>/dev/null; then
  sudo sed -i "s|^.*JAVA_HOME.*$|export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64|" "${HADOOP_ENV_FILE}" || true
else
  echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64" | sudo tee -a "${HADOOP_ENV_FILE}" >/dev/null
fi

mkdir -p ~/hadoopdata/namenode
mkdir -p ~/hadoopdata/datanode

cat > "${HADOOP_HOME}/etc/hadoop/core-site.xml" <<'XML'
<configuration>
 <property>
   <name>fs.defaultFS</name>
   <value>hdfs://localhost:9000</value>
 </property>
</configuration>
XML

cat > "${HADOOP_HOME}/etc/hadoop/hdfs-site.xml" <<XML
<configuration>
 <property>
   <name>dfs.replication</name>
   <value>1</value>
 </property>
 <property>
   <name>dfs.namenode.name.dir</name>
   <value>file:///home/vscode/hadoopdata/namenode</value>
 </property>
 <property>
   <name>dfs.datanode.data.dir</name>
   <value>file:///home/vscode/hadoopdata/datanode</value>
 </property>
</configuration>
XML

if [ ! -d ~/hadoopdata/namenode/current ]; then
  echo "Formatting NameNode..."
  "${HADOOP_HOME}/bin/hdfs" namenode -format -force -nonInteractive
fi

cat > ~/start-hadoop.sh <<EOF
#!/usr/bin/env bash
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_HOME=${HADOOP_HOME}
export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin

\$HADOOP_HOME/bin/hdfs --daemon start namenode
\$HADOOP_HOME/bin/hdfs --daemon start datanode
\$HADOOP_HOME/sbin/yarn-daemon.sh start resourcemanager
\$HADOOP_HOME/sbin/yarn-daemon.sh start nodemanager

echo "Hadoop started. NameNode UI: http://localhost:9870   YARN UI: http://localhost:8088"
EOF
chmod +x ~/start-hadoop.sh

cat > ~/stop-hadoop.sh <<EOF
#!/usr/bin/env bash
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_HOME=${HADOOP_HOME}
export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin

\$HADOOP_HOME/sbin/yarn-daemon.sh stop nodemanager
\$HADOOP_HOME/sbin/yarn-daemon.sh stop resourcemanager
\$HADOOP_HOME/bin/hdfs --daemon stop datanode
\$HADOOP_HOME/bin/hdfs --daemon stop namenode
echo "Hadoop stopped."
EOF
chmod +x ~/stop-hadoop.sh

echo "POST-CREATE finished."
