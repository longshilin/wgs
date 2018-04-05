import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mrunit.mapreduce.MapDriver;
import org.junit.Test;

import java.io.IOException;

public class comparisonMapperTest {

    /*
        测试比对脚本
     */
    @Test
    public void comparison() throws IOException {
        Text value = new Text("SRR1770413");

        new MapDriver<LongWritable, Text, Text, Text>()
                .withMapper(new comparisonMapper())
                .withInput(new LongWritable(0), value)
                .withOutput(new Text("1"), value)
                .runTest();

    }

}