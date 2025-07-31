/* preferences-dialog.vala
 *
 * 中国象棋首选项对话框
 */

public class PreferencesDialog : Adw.PreferencesWindow {
    // 首选项控件
    private Gtk.Switch animation_switch;
    private Gtk.Switch sound_switch;
    private Gtk.Switch highlight_switch;
    
    public PreferencesDialog (Gtk.Window parent) {
        Object (
            title: "首选项",
            transient_for: parent,
            modal: true
        );
        
        // 创建首选项页面
        var page = new Adw.PreferencesPage ();
        
        // 创建外观组
        var appearance_group = new Adw.PreferencesGroup () {
            title = "外观"
        };
        
        // 动画效果
        var animation_row = new Adw.ActionRow () {
            title = "动画效果",
            subtitle = "启用棋子移动动画"
        };
        
        animation_switch = new Gtk.Switch () {
            valign = Gtk.Align.CENTER,
            active = true
        };
        
        animation_row.add_suffix (animation_switch);
        animation_row.activatable_widget = animation_switch;
        appearance_group.add (animation_row);
        
        // 高亮显示
        var highlight_row = new Adw.ActionRow () {
            title = "高亮显示",
            subtitle = "高亮显示可移动位置和选中棋子"
        };
        
        highlight_switch = new Gtk.Switch () {
            valign = Gtk.Align.CENTER,
            active = true
        };
        
        highlight_row.add_suffix (highlight_switch);
        highlight_row.activatable_widget = highlight_switch;
        appearance_group.add (highlight_row);
        
        // 创建声音组
        var sound_group = new Adw.PreferencesGroup () {
            title = "声音"
        };
        
        // 音效
        var sound_row = new Adw.ActionRow () {
            title = "音效",
            subtitle = "启用游戏音效"
        };
        
        sound_switch = new Gtk.Switch () {
            valign = Gtk.Align.CENTER,
            active = true
        };
        
        sound_row.add_suffix (sound_switch);
        sound_row.activatable_widget = sound_switch;
        sound_group.add (sound_row);
        
        // 添加组到页面
        page.add (appearance_group);
        page.add (sound_group);
        
        // 添加页面到窗口
        add (page);
        
        // 连接信号
        animation_switch.notify["active"].connect (() => {
            // 保存设置
        });
        
        highlight_switch.notify["active"].connect (() => {
            // 保存设置
        });
        
        sound_switch.notify["active"].connect (() => {
            // 保存设置
        });
    }
}