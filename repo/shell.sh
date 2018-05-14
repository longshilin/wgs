
#### Unix下执行Test类 ####
export CLASSPATH=/opt/repo/junit/junit/4.12/junit-4.12.jar:/home/elon/IdeaProjects/wgs/wgsv3/wgsv3.jar
java org.junit.runner.JUnitCore wgsMapperTest

# 或者使用如下命令
java -cp /opt/repo/junit/junit/4.12/junit-4.12.jar:/home/elon/IdeaProjects/wgs/wgsv3/wgsv3.jar org.junit.runner.JUnitCore wgsMapperTest
