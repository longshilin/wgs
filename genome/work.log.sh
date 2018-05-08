# 使用idea只用打包class文件即可，java类中指定的模板及脚本文件等存于~/genome文件夹中

# 提交作业到集群上
hadoop jar ~/IdeaProjects/wgs/wgsv3/wgs.jar wgsDriver -libjars ~/genome/bin/freemarker-2.3.27-incubating.jar hdfs://longsl:8080/wgsv3-input/sample.txt hdfs://longsl:8080/wgsv3-output

注意mapreduce内存的配置和shell脚本内存容量的设置问题
#ref：https://stackoverflow.com/questions/21005643/container-is-running-beyond-memory-limits/25321010
