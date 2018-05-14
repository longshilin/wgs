import org.apache.hadoop.io.Text;
import org.apache.hadoop.mrunit.mapreduce.ReduceDriver;
import org.junit.Test;
import java.io.IOException;
import java.util.Arrays;

public class wgsReducerTest {
    /*
        测试Reducer
     */
    @Test
    public void merge() throws IOException {
        Text value1 = new Text("SRR3226034");
        Text value2 = new Text("SRR3226035");
        Text value3 = new Text("SRR3226036");
        Text value4 = new Text("SRR3226037");
        Text value5 = new Text("SRR3226038");
        Text value6 = new Text("SRR3226039");
        Text value7 = new Text("SRR3226040");
        Text value8 = new Text("SRR3226041");
        Text value9 = new Text("SRR3226042");
        new ReduceDriver<Text, Text, Text, Text>()
                .withReducer(new wgsReducer())
                .withInputKey(new Text("1"))
                .withInputValues(Arrays.asList(value1,value2,value3,value4,value5,value6,value7,value8,value9))
                .withOutput(new Text("1"), value9)
                .runTest();
    }
}