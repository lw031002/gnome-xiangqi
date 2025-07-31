/* new-game-dialog.vala
 *
 * 中国象棋新游戏对话框
 */

public class NewGameDialog : Adw.Window {
    // 对话框控件
    private Gtk.DropDown player_type_dropdown;
    private Gtk.DropDown difficulty_dropdown;
    private Gtk.Button start_button;
    private Gtk.Button cancel_button;
    
    // 信号
    public signal void game_started (bool against_computer, int difficulty);
    
    public NewGameDialog (Gtk.Window parent) {
        Object (
            title: "新游戏",
            transient_for: parent,
            modal: true,
            resizable: false,
            width_request: 400
        );
        
        // 创建主布局
        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 24);
        main_box.margin_start = 24;
        main_box.margin_end = 24;
        main_box.margin_top = 24;
        main_box.margin_bottom = 24;
        
        // 创建标题
        var title_label = new Gtk.Label ("开始新游戏");
        title_label.add_css_class ("title-1");
        main_box.append (title_label);
        
        // 创建选项网格
        var grid = new Gtk.Grid ();
        grid.row_spacing = 12;
        grid.column_spacing = 12;
        
        // 对手类型
        var player_type_label = new Gtk.Label ("对手类型：");
        player_type_label.halign = Gtk.Align.START;
        grid.attach (player_type_label, 0, 0, 1, 1);
        
        var player_types = new Gtk.StringList ({"人类玩家", "电脑"});
        player_type_dropdown = new Gtk.DropDown (player_types, null);
        player_type_dropdown.hexpand = true;
        grid.attach (player_type_dropdown, 1, 0, 1, 1);
        
        // 难度级别
        var difficulty_label = new Gtk.Label ("难度级别：");
        difficulty_label.halign = Gtk.Align.START;
        grid.attach (difficulty_label, 0, 1, 1, 1);
        
        var difficulties = new Gtk.StringList ({"简单", "中等", "困难"});
        difficulty_dropdown = new Gtk.DropDown (difficulties, null);
        difficulty_dropdown.hexpand = true;
        difficulty_dropdown.sensitive = false;  // 默认禁用
        grid.attach (difficulty_dropdown, 1, 1, 1, 1);
        
        main_box.append (grid);
        
        // 创建按钮区域
        var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        button_box.halign = Gtk.Align.END;
        button_box.margin_top = 24;
        
        cancel_button = new Gtk.Button.with_label ("取消");
        button_box.append (cancel_button);
        
        start_button = new Gtk.Button.with_label ("开始");
        start_button.add_css_class ("suggested-action");
        button_box.append (start_button);
        
        main_box.append (button_box);
        
        // 设置主布局为窗口的子元素
        set_content (main_box);
        
        // 连接信号
        player_type_dropdown.notify["selected"].connect (() => {
            difficulty_dropdown.sensitive = (player_type_dropdown.selected == 1);
        });
        
        cancel_button.clicked.connect (() => {
            close ();
        });
        
        start_button.clicked.connect (() => {
            bool against_computer = (player_type_dropdown.selected == 1);
            int difficulty = (int) difficulty_dropdown.selected;
            game_started (against_computer, difficulty);
            close ();
        });
    }
}