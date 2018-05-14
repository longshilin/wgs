import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.NLineInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

/*
    MapReduce的驱动类，主要对Mapper和Reducer类进行配置和调度
 */

public class wgsDriver extends Configured implements Tool {

    @Override
    public int run(String[] args) throws Exception {

        if (args.length != 2) {
            System.err.printf("Usage: %s [generic options] <input> <output>\n",
                    getClass().getSimpleName());
            ToolRunner.printGenericCommandUsage(System.err);
            return -1;
        }

        Configuration conf = new Configuration();

        // 设置hadoop采用本地模式执行作业
        conf.set("mapred.job.tracker", "local");
        // 输入文件的每一行用一个mapper来处理
        conf.setInt(NLineInputFormat.LINES_PER_MAP, 1);

        Job job = new Job(getConf(), "wgs-v3");
        job.setJarByClass(getClass());

        FileInputFormat.addInputPath(job, new Path(args[0]));
        Path outPath = new Path(args[1]);
        FileOutputFormat.setOutputPath(job, outPath);
        outPath.getFileSystem(conf).delete(outPath, true); // 提前删除已存在的输出文件夹

        // 设置Mapper和Reducer的类
        job.setMapperClass(wgsMapper.class);
        job.setReducerClass(wgsReducer.class);

        // 设置job任务输出的<key,value>数据类型
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(Text.class);

        return job.waitForCompletion(true) ? 0 : 1;
    }

    public static void main(String[] args) throws Exception {
        int exitCode = ToolRunner.run(new wgsDriver(), args);
        System.exit(exitCode);
    }
}
