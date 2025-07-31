/* gnome-xiangqi.vala
 *
 * 中国象棋主程序入口
 */

public class XiangqiApplication : Adw.Application {
    public XiangqiApplication () {
        Object (
            application_id: "org.gnome.Xiangqi",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }
    
    protected override void activate () {
        var window = new XiangqiWindow (this);
        window.present ();
    }
    
    public static int main (string[] args) {
        return new XiangqiApplication ().run (args);
    }
}