import org.apache.hadoop.io.Text;
import org.apache.hadoop.mrunit.mapreduce.ReduceDriver;
import org.junit.Test;

import java.io.IOException;
import java.util.Arrays;

public class comparisonReducerTest {
    /*
        测试比对脚本
     */
    @Test
    public void merge() throws IOException {
        Text value1 = new Text("SRR3226035");
        Text value2 = new Text("SRR3226039");
        Text value3 = new Text("SRR3226042");
        new ReduceDriver<Text, Text, Text, Text>()
                .withReducer(new comparisonReducer())
                .withInputKey(new Text("1"))
                .withInputValues(Arrays.asList(value1,value2,value3))
                .withOutput(new Text("1"), value3)
                .runTest();


    }
}