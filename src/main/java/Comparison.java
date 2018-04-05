import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.NLineInputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

import java.io.IOException;

public class Comparison extends Configured implements Tool {


    public static class ComparisonMapper extends Mapper<Object, Text, Text, IntWritable> {
        public void map(LongWritable key, Text value, Mapper.Context context) throws IOException, InterruptedException {


        }

    }

    public static class ComparisonReducer extends Reducer<Text, IntWritable, Text, Text> {

        public void reduce(Text key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {


        }
    }

    public int run(String[] args) throws Exception {

        if (args.length != 2) {
            System.err.println("Usage: Comparison <input path> <output path>");
        }
        Configuration conf = new Configuration();

        conf.setInt(org.apache.hadoop.mapreduce.lib.input.NLineInputFormat.LINES_PER_MAP, 1);

        Job job = new Job(conf, "Comparison");
        job.setJarByClass(Comparison.class);

        job.setInputFormatClass(NLineInputFormat.class);
        job.setMapperClass(ComparisonMapper.class);

        job.setReducerClass(ComparisonReducer.class);

        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(Text.class);

        FileInputFormat.setInputPaths(job, new Path(args[0]));

        Path outPath = new Path(args[1]);
        org.apache.hadoop.mapreduce.lib.output.FileOutputFormat.setOutputPath(job, outPath);
        outPath.getFileSystem(conf).delete(outPath, true);

        job.waitForCompletion(true);

        return (job.waitForCompletion(true) ? 0 : 1);
    }

    // 函数主入口
    public static void main(String[] args) throws Exception {
        int exitCode = ToolRunner.run(new Comparison(), args);
        System.exit(exitCode);
    }
}
