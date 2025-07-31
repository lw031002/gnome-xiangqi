/* xiangqi-clock.vala
 *
 * 中国象棋时钟类
 */

public class XiangqiClock : Object {
    // 信号
    public signal void tick ();
    public signal void time_expired (XiangqiColor color);
    
    // 时间（秒）
    public int red_time { get; set; default = 0; }
    public int black_time { get; set; default = 0; }
    
    // 当前活动的时钟
    public XiangqiColor active_color { get; private set; default = XiangqiColor.RED; }
    
    // 计时器
    private uint timer_id = 0;
    private bool is_running = false;
    
    public XiangqiClock () {
    }
    
    // 设置初始时间
    public void set_time (int seconds) {
        red_time = seconds;
        black_time = seconds;
    }
    
    // 启动时钟
    public void start () {
        if (is_running) {
            return;
        }
        
        is_running = true;
        timer_id = Timeout.add_seconds (1, tick_callback);
    }
    
    // 停止时钟
    public void stop () {
        if (!is_running) {
            return;
        }
        
        is_running = false;
        if (timer_id > 0) {
            Source.remove (timer_id);
            timer_id = 0;
        }
    }
    
    // 切换活动时钟
    public void switch_clock () {
        active_color = (active_color == XiangqiColor.RED) ? XiangqiColor.BLACK : XiangqiColor.RED;
    }
    
    // 时钟回调
    private bool tick_callback () {
        if (active_color == XiangqiColor.RED) {
            if (red_time > 0) {
                red_time--;
            }
            
            if (red_time == 0) {
                time_expired (XiangqiColor.RED);
                stop ();
                return false;
            }
        } else {
            if (black_time > 0) {
                black_time--;
            }
            
            if (black_time == 0) {
                time_expired (XiangqiColor.BLACK);
                stop ();
                return false;
            }
        }
        
        tick ();
        return true;
    }
    
    // 获取格式化的时间字符串
    public string get_time_string (XiangqiColor color) {
        int time = (color == XiangqiColor.RED) ? red_time : black_time;
        int minutes = time / 60;
        int seconds = time % 60;
        
        return "%02d:%02d".printf (minutes, seconds);
    }
}