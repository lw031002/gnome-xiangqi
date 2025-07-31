/* xiangqi-window.vala
 *
 * 中国象棋主窗口类
 */

public class XiangqiWindow : Adw.ApplicationWindow {
    // UI元素
    private XiangqiView view;
    private Gtk.Label status_label;
    private Gtk.Button undo_button;
    private Gtk.MenuButton menu_button;
    
    // 导航按钮
    private Gtk.Button first_move_button;
    private Gtk.Button prev_move_button;
    private Gtk.Button next_move_button;
    private Gtk.Button last_move_button;
    private Gtk.DropDown history_dropdown;
    
    // 计时器
    private Gtk.Label red_timer_label;
    private Gtk.Label black_timer_label;
    private uint timer_id;
    private int red_seconds;
    private int black_seconds;
    
    // 移动记录已移除
    
    // 游戏对象
    private XiangqiGame game;
    
    // 菜单模型
    private GLib.Menu app_menu;
    
    // 历史记录模型
    private Gtk.StringList history_model;
    
    // 响应式设计
    private bool is_compact_mode = false;
    
    // 当前查看的历史步骤
    private int current_history_index = 0;
    
    // 保存所有历史状态
    private List<XiangqiState> history_states = new List<XiangqiState>();
    
    // 是否正在查看历史
    private bool viewing_history = false;
    
    public XiangqiWindow (Gtk.Application app) {
        Object (application: app);
        
        // 设置标题和默认尺寸
        title = "中国象棋";
        default_width = 800;
        default_height = 900;
        
        // 初始化历史状态列表
        history_states = new List<XiangqiState>();
        
        // 创建主布局
        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        
        // 创建头部栏
        var header_bar = new Adw.HeaderBar ();
        
        // 创建标题标签（显示当前玩家）
        status_label = new Gtk.Label ("红方走子");
        status_label.add_css_class ("title");
        header_bar.set_title_widget (status_label);
        
        // 创建悔棋按钮
        undo_button = new Gtk.Button.from_icon_name ("edit-undo-symbolic");
        undo_button.tooltip_text = "悔棋 (Ctrl+Z)";
        undo_button.action_name = "win.undo";
        header_bar.pack_start (undo_button);
        
        // 创建菜单按钮
        menu_button = new Gtk.MenuButton ();
        menu_button.icon_name = "open-menu-symbolic";
        menu_button.tooltip_text = "主菜单";
        header_bar.pack_end (menu_button);
        
        // 设置头部栏
        main_box.append (header_bar);
        
        // 创建内容区域
        var content_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        content_box.hexpand = true;
        content_box.vexpand = true;
        
        // 创建视图
        view = new XiangqiView ();
        view.hexpand = true;
        view.vexpand = true;
        content_box.append (view);
        
        // 创建状态栏
        var status_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        status_box.margin_start = 12;
        status_box.margin_end = 12;
        status_box.margin_top = 6;
        status_box.margin_bottom = 6;
        
        // 创建导航按钮（左对齐）
        var nav_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        
        first_move_button = new Gtk.Button.from_icon_name ("go-first-symbolic");
        first_move_button.tooltip_text = "第一步";
        first_move_button.sensitive = false;
        first_move_button.clicked.connect (on_first_move_clicked);
        
        prev_move_button = new Gtk.Button.from_icon_name ("go-previous-symbolic");
        prev_move_button.tooltip_text = "上一步";
        prev_move_button.sensitive = false;
        prev_move_button.clicked.connect (on_prev_move_clicked);
        
        next_move_button = new Gtk.Button.from_icon_name ("go-next-symbolic");
        next_move_button.tooltip_text = "下一步";
        next_move_button.sensitive = false;
        next_move_button.clicked.connect (on_next_move_clicked);
        
        last_move_button = new Gtk.Button.from_icon_name ("go-last-symbolic");
        last_move_button.tooltip_text = "最后一步";
        last_move_button.sensitive = false;
        last_move_button.clicked.connect (on_last_move_clicked);
        
        nav_box.append (first_move_button);
        nav_box.append (prev_move_button);
        nav_box.append (next_move_button);
        nav_box.append (last_move_button);
        
        status_box.append (nav_box);
        
        // 创建历史记录下拉菜单
        history_model = new Gtk.StringList (null);
        history_model.append ("开始");
        history_dropdown = new Gtk.DropDown (history_model, null);
        history_dropdown.selected = 0;
        history_dropdown.notify["selected"].connect (on_history_selected);
        history_dropdown.hexpand = true; // 拉伸以适应剩余空间
        
        // 自定义下拉菜单的显示
        var list_factory = history_dropdown.get_factory ();
        var button_factory = new Gtk.SignalListItemFactory ();
        
        button_factory.setup.connect (history_dropdown_button_setup_cb);
        button_factory.bind.connect (history_dropdown_button_bind_cb);
        
        history_dropdown.set_factory (button_factory);
        history_dropdown.set_list_factory (list_factory);
        
        // 创建计时器（右对齐）
        var timer_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        
        red_timer_label = new Gtk.Label ("红方: 00:00");
        
        black_timer_label = new Gtk.Label ("黑方: 00:00");
        
        timer_box.append (red_timer_label);
        timer_box.append (black_timer_label);
        
        // 将历史记录下拉菜单和计时器添加到状态栏
        status_box.append (history_dropdown);
        status_box.append (timer_box);
        
        content_box.append (status_box);
        
        // 添加内容区域到主布局
        main_box.append (content_box);
        
        // 设置主布局为窗口的子元素
        set_content (main_box);
        
        // 响应式设计已移除，不再需要
        
        // 初始化游戏
        game = new XiangqiGame ();
        view.initialize_game (game);
        
        // 连接信号
        game.player_changed.connect (on_player_changed);
        game.game_over.connect (on_game_over);
        game.piece_moved.connect (on_piece_moved);
        game.check_occurred.connect (on_check_occurred);
        
        // 移动记录标签已移除
        
        // 设置动作
        setup_actions ();
        
        // 设置菜单
        setup_menu ();
        
        // 设置CSS样式
        setup_css ();
        
        // 开始新游戏
        // 开始新游戏
        game.new_game ();
        
        // 重要：新游戏后需要重新设置视图的状态引用
        view.update_game_state ();
        
        // 启动计时器
        start_timer ();
    }
    
    // 设置CSS样式
    private void setup_css () {
        var provider = new Gtk.CssProvider ();
        provider.load_from_data ("""
            .timer {
                font-size: 24px;
                font-weight: bold;
            }
            .heading {
                font-weight: bold;
            }
            .red {
                color: #c00;
            }
            .black {
                color: #000;
            }
        """.data);
        
        Gtk.StyleContext.add_provider_for_display (
            Gdk.Display.get_default (),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );
    }
    
    // 设置动作
    private void setup_actions () {
        // 新游戏动作
        var new_game_action = new SimpleAction ("new-game", null);
        new_game_action.activate.connect (on_new_game_activated);
        add_action (new_game_action);
        
        // 保存游戏动作
        var save_game_action = new SimpleAction ("save-game", null);
        save_game_action.activate.connect (on_save_game_activated);
        add_action (save_game_action);
        
        // 加载游戏动作
        var load_game_action = new SimpleAction ("load-game", null);
        load_game_action.activate.connect (on_load_game_activated);
        add_action (load_game_action);
        
        // 退出动作
        var quit_action = new SimpleAction ("quit", null);
        quit_action.activate.connect (on_quit_activated);
        add_action (quit_action);
        
        // 悔棋动作
        var undo_action = new SimpleAction ("undo", null);
        undo_action.activate.connect (on_undo_activated);
        add_action (undo_action);
        
        // 重做动作
        var redo_action = new SimpleAction ("redo", null);
        redo_action.activate.connect (on_redo_activated);
        add_action (redo_action);
        
        // 旋转棋盘动作
        var rotate_board_action = new SimpleAction ("rotate-board", null);
        rotate_board_action.activate.connect (on_rotate_board_activated);
        add_action (rotate_board_action);
        
        // 首选项动作
        var preferences_action = new SimpleAction ("preferences", null);
        preferences_action.activate.connect (on_preferences_activated);
        add_action (preferences_action);
        
        // 帮助动作
        var help_action = new SimpleAction ("help", null);
        help_action.activate.connect (on_help_activated);
        add_action (help_action);
        
        // 关于动作
        var about_action = new SimpleAction ("about", null);
        about_action.activate.connect (on_about_activated);
        add_action (about_action);
        
        // 添加快捷键
        application.set_accels_for_action ("win.new-game", {"<Control>n"});
        application.set_accels_for_action ("win.save-game", {"<Control>s"});
        application.set_accels_for_action ("win.load-game", {"<Control>o"});
        application.set_accels_for_action ("win.quit", {"<Control>q"});
        application.set_accels_for_action ("win.undo", {"<Control>z"});
        application.set_accels_for_action ("win.redo", {"<Control>y"});
        application.set_accels_for_action ("win.rotate-board", {"<Control>r"});
        application.set_accels_for_action ("win.preferences", {"<Control>p"});
        application.set_accels_for_action ("win.help", {"F1"});
        application.set_accels_for_action ("win.about", {"<Shift>F1"});
    }
    
    // 设置菜单
    private void setup_menu () {
        // 创建应用菜单
        app_menu = new GLib.Menu ();
        
        // 游戏菜单部分
        var game_section = new GLib.Menu ();
        game_section.append ("新游戏", "win.new-game");
        game_section.append ("保存游戏", "win.save-game");
        game_section.append ("加载游戏", "win.load-game");
        app_menu.append_section (null, game_section);
        
        // 编辑菜单部分
        var edit_section = new GLib.Menu ();
        edit_section.append ("悔棋", "win.undo");
        edit_section.append ("重做", "win.redo");
        edit_section.append ("旋转棋盘", "win.rotate-board");
        app_menu.append_section (null, edit_section);
        
        // 设置菜单部分
        var settings_section = new GLib.Menu ();
        settings_section.append ("首选项", "win.preferences");
        app_menu.append_section (null, settings_section);
        
        // 帮助菜单部分
        var help_section = new GLib.Menu ();
        help_section.append ("帮助", "win.help");
        help_section.append ("关于", "win.about");
        app_menu.append_section (null, help_section);
        
        // 设置菜单按钮的菜单模型
        menu_button.set_menu_model (app_menu);
    }
    
    // 启动计时器
    private void start_timer () {
        red_seconds = 0;
        black_seconds = 0;
        update_timer_labels ();
        
        timer_id = Timeout.add_seconds (1, () => {
            if (game.state.game_over) {
                return true;
            }
            
            if (game.state.current_player == XiangqiColor.RED) {
                red_seconds++;
            } else {
                black_seconds++;
            }
            
            update_timer_labels ();
            return true;
        });
    }
    
    // 更新计时器标签
    private void update_timer_labels () {
        red_timer_label.set_text ("红方: %02d:%02d".printf (red_seconds / 60, red_seconds % 60));
        black_timer_label.set_text ("黑方: %02d:%02d".printf (black_seconds / 60, black_seconds % 60));
    }
    
    // 新游戏动作激活事件
    // 新游戏动作激活事件
    private void on_new_game_activated (SimpleAction action, Variant? parameter) {
        var dialog = new NewGameDialog (this);
        dialog.game_started.connect ((against_computer, difficulty) => {
            game.new_game ();
            // 重要：新游戏后需要重新设置视图的状态引用
            view.update_game_state ();
            // 重置计时器
            red_seconds = 0;
            black_seconds = 0;
            update_timer_labels ();
            
            // 重置历史记录
            history_model.splice (0, history_model.get_n_items (), null);
            history_model.append ("开始");
            history_dropdown.selected = 0;
            current_history_index = -1;
            
            // 更新导航按钮状态
            update_navigation_buttons ();
            
            // TODO: 设置对手类型和难度
        });
        dialog.present ();
    }
    
    // 悔棋动作激活事件
    private void on_undo_activated (SimpleAction action, Variant? parameter) {
        if (game.undo_move ()) {
            // 移除最后一步的历史记录
            if (history_model.get_n_items () > 1) {
                history_model.remove (history_model.get_n_items () - 1);
            }
            
            // 移除最后一个历史状态
            if (history_states.length () > 0) {
                history_states.delete_link (history_states.last ());
            }
            
            // 更新当前历史索引
            current_history_index = history_model.get_n_items () > 1 ? (int)(history_model.get_n_items () - 2) : 0;
            
            // 自动跟随最新的移动
            history_dropdown.selected = history_model.get_n_items () - 1;
            
            // 更新导航按钮状态
            update_navigation_buttons ();
            
            // 如果正在查看历史，恢复到当前状态
            if (viewing_history) {
                viewing_history = false;
                view.restore_current_state();
            }
            
            // 重置状态标签（清除将军提示）
            status_label.set_text ((game.state.current_player == XiangqiColor.RED) ? "红方走子" : "黑方走子");
        }
    }
    
    // 重做动作激活事件
    private void on_redo_activated (SimpleAction action, Variant? parameter) {
        // TODO: 实现重做功能
    }
    
    // 保存游戏动作激活事件
    private void on_save_game_activated (SimpleAction action, Variant? parameter) {
        // TODO: 实现保存游戏功能
    }
    
    // 加载游戏动作激活事件
    private void on_load_game_activated (SimpleAction action, Variant? parameter) {
        // TODO: 实现加载游戏功能
    }
    
    // 退出动作激活事件
    private void on_quit_activated (SimpleAction action, Variant? parameter) {
        close ();
    }
    
    // 旋转棋盘动作激活事件
    private void on_rotate_board_activated (SimpleAction action, Variant? parameter) {
        // TODO: 实现旋转棋盘功能
    }
    
    // 首选项动作激活事件
    private void on_preferences_activated (SimpleAction action, Variant? parameter) {
        var dialog = new PreferencesDialog (this);
        dialog.present ();
    }
    
    // 帮助动作激活事件
    private void on_help_activated (SimpleAction action, Variant? parameter) {
        // TODO: 实现帮助功能
    }
    
    // 关于动作激活事件
    private void on_about_activated (SimpleAction action, Variant? parameter) {
        var about = new Adw.AboutWindow () {
            application_name = "中国象棋",
            application_icon = "org.gnome.Xiangqi",
            version = "1.0.0",
            copyright = "© 2023",
            license_type = Gtk.License.GPL_3_0,
            website = "https://github.com/gnome/gnome-xiangqi",
            transient_for = this
        };
        
        about.present ();
    }
    
    // 第一步按钮点击事件
    private void on_first_move_clicked () {
        // 设置为查看历史模式
        viewing_history = true;
        
        // 选择第一步（开始状态）
        history_dropdown.selected = 0;
        
        // 创建一个新的初始状态
        var initial_state = new XiangqiState();
        
        // 更新视图
        view.set_temporary_state(initial_state);
    }
    
    // 上一步按钮点击事件
    private void on_prev_move_clicked () {
        if (history_dropdown.selected > 0) {
            // 设置为查看历史模式
            viewing_history = true;
            
            // 选择上一步
            history_dropdown.selected--;
            
            // 如果是第一步（开始状态）
            if (history_dropdown.selected == 0) {
                // 创建一个新的初始状态
                var initial_state = new XiangqiState();
                // 更新视图
                view.set_temporary_state(initial_state);
            } else {
                // 获取上一步的历史状态
                var history_state = history_states.nth_data(history_dropdown.selected - 1);
                // 更新视图
                view.set_temporary_state(history_state);
            }
        }
    }
    
    // 下一步按钮点击事件
    private void on_next_move_clicked () {
        if (history_dropdown.selected < history_model.get_n_items() - 1) {
            // 设置为查看历史模式
            viewing_history = true;
            
            // 选择下一步
            history_dropdown.selected++;
            
            // 如果是最后一步
            if (history_dropdown.selected == history_model.get_n_items() - 1) {
                // 恢复到当前游戏状态
                viewing_history = false;
                view.restore_current_state();
            } else {
                // 获取下一步的历史状态
                var history_state = history_states.nth_data(history_dropdown.selected - 1);
                // 更新视图
                view.set_temporary_state(history_state);
            }
        }
    }
    
    // 最后一步按钮点击事件
    private void on_last_move_clicked () {
        // 选择最后一步
        history_dropdown.selected = history_model.get_n_items() - 1;
        
        // 恢复到当前游戏状态
        viewing_history = false;
        view.restore_current_state();
    }
    
    // 历史记录下拉菜单按钮设置回调
    private void history_dropdown_button_setup_cb (Gtk.SignalListItemFactory factory, Object object) {
        unowned var list_item = object as Gtk.ListItem;
        
        list_item.child = new Gtk.Label (null) {
            ellipsize = Pango.EllipsizeMode.END,
            xalign = 0
        };
    }
    
    // 历史记录下拉菜单按钮绑定回调
    private void history_dropdown_button_bind_cb (Gtk.SignalListItemFactory factory, Object object) {
        unowned var list_item = object as Gtk.ListItem;
        unowned var string_object = list_item.item as Gtk.StringObject;
        unowned var label = list_item.child as Gtk.Label;
        
        label.label = string_object.string;
    }
    
    // 历史记录选择事件
    private void on_history_selected () {
        int selected = (int) history_dropdown.selected;
        
        // 如果选择了历史记录中的某一步
        if (selected >= 0 && selected < (int)history_states.length()) {
            // 设置为查看历史模式
            viewing_history = true;
            
            // 保存当前历史索引
            current_history_index = selected;
            
            // 如果选择了"开始"状态
            if (selected == 0) {
                // 创建一个新的初始状态
                var initial_state = new XiangqiState();
                // 更新视图
                view.set_temporary_state(initial_state);
            } else {
                // 获取选中的历史状态
                var history_state = history_states.nth_data(selected - 1);
                // 更新视图
                view.set_temporary_state(history_state);
            }
            
            // 更新导航按钮状态
            update_navigation_buttons();
        }
    }
    
    // 更新导航按钮状态
    private void update_navigation_buttons () {
        int history_count = (int) history_model.get_n_items ();
        
        first_move_button.sensitive = history_count > 1 && history_dropdown.selected > 0;
        prev_move_button.sensitive = history_count > 1 && history_dropdown.selected > 0;
        next_move_button.sensitive = history_count > 1 && history_dropdown.selected < history_count - 1;
        last_move_button.sensitive = history_count > 1 && history_dropdown.selected < history_count - 1;
    }
    
    // 棋子移动事件处理
    private void on_piece_moved (XiangqiPiece piece, int from_file, int from_rank, int to_file, int to_rank) {
        // 直接使用传入的参数构建移动描述
        string move_text = generate_move_text(piece, from_file, from_rank, to_file, to_rank);
        
        // 添加移动记录到历史下拉菜单
        history_model.append(move_text);
        
        // 保存当前状态的副本
        var state_copy = clone_state(game.state);
        history_states.append(state_copy);
        
        // 自动跟随最新的移动
        history_dropdown.selected = history_model.get_n_items() - 1;
        
        // 更新当前历史索引
        current_history_index = (int)(history_model.get_n_items() - 2);
        
        // 更新导航按钮状态
        update_navigation_buttons();
        
        // 如果正在查看历史，恢复到当前状态
        if (viewing_history) {
            viewing_history = false;
            view.restore_current_state();
        }
    }
    
    // 将军事件处理
    private void on_check_occurred (XiangqiColor checked_color) {
        // 显示将军提示
        string color_name = checked_color == XiangqiColor.RED ? "红方" : "黑方";
        status_label.set_text(color_name + "被将军！");
        
        // 可以添加其他视觉或声音提示
    }
    
    // 克隆状态对象（用于历史记录）
    private XiangqiState clone_state(XiangqiState original) {
        var clone = new XiangqiState();
        
        // 清空默认棋子
        clone.pieces = new List<XiangqiPiece>();
        
        // 复制所有棋子
        foreach (var piece in original.pieces) {
            var piece_copy = new XiangqiPiece(piece.piece_type, piece.color, piece.file, piece.rank);
            piece_copy.captured = piece.captured;
            clone.pieces.append(piece_copy);
        }
        
        // 复制当前玩家
        clone.current_player = original.current_player;
        
        // 复制游戏结束状态
        clone.game_over = original.game_over;
        
        return clone;
    }
    
    // 生成移动文本描述（中国象棋标准记谱法）
    private string generate_move_text (XiangqiPiece piece, int from_file, int from_rank, int to_file, int to_rank) {
        string move_text = "";
        string prefix = piece.color == XiangqiColor.RED ? "红" : "黑";
        
        // 获取棋子名称
        string piece_name = get_piece_name(piece.piece_type, piece.color);
        
        // 获取起始位置的列数（中文数字表示）
        string file_name = get_file_name(from_file, piece.color);
        
        // 判断移动方向
        if (from_file == to_file) {
            // 如果是同一列，则是"进"或"退"
            string direction = piece.color == XiangqiColor.RED ? 
                (to_rank < from_rank ? "进" : "退") : 
                (to_rank > from_rank ? "进" : "退");
            
            // 计算移动的步数
            int steps = (from_rank - to_rank).abs();
            string step_name = get_step_name(steps);
            
            move_text = "%s: %s%s%s%s".printf(prefix, piece_name, file_name, direction, step_name);
        } else {
            // 如果是不同列，则是"平"
            string direction = "平";
            string target_file = get_file_name(to_file, piece.color);
            
            move_text = "%s: %s%s%s%s".printf(prefix, piece_name, file_name, direction, target_file);
        }
        
        return move_text;
    }
    
    // 玩家变更事件处理
    private void on_player_changed (XiangqiColor color) {
        status_label.set_text ((color == XiangqiColor.RED) ? "红方走子" : "黑方走子");
    }
    
    // 游戏结束事件处理
    private void on_game_over (XiangqiColor? winner) {
        if (winner == XiangqiColor.RED) {
            status_label.set_text ("红方胜利！");
        } else if (winner == XiangqiColor.BLACK) {
            status_label.set_text ("黑方胜利！");
        } else {
            status_label.set_text ("和棋");
        }
    }
    
    // 获取棋子名称（根据类型和颜色）
    private string get_piece_name(XiangqiPieceType type, XiangqiColor color) {
        switch (type) {
            case XiangqiPieceType.GENERAL:
                return color == XiangqiColor.RED ? "帅" : "将";
            case XiangqiPieceType.ADVISOR:
                return color == XiangqiColor.RED ? "仕" : "士";
            case XiangqiPieceType.ELEPHANT:
                return color == XiangqiColor.RED ? "相" : "象";
            case XiangqiPieceType.HORSE:
                return "马";
            case XiangqiPieceType.CHARIOT:
                return "车";
            case XiangqiPieceType.CANNON:
                return "炮";
            case XiangqiPieceType.SOLDIER:
                return color == XiangqiColor.RED ? "兵" : "卒";
            default:
                return "未知";
        }
    }
    
    // 获取列名称（根据颜色，红方从右到左1-9，黑方从左到右9-1）
    private string get_file_name(int file, XiangqiColor color) {
        string[] chinese_numbers = {"一", "二", "三", "四", "五", "六", "七", "八", "九"};
        
        if (color == XiangqiColor.RED) {
            // 红方从右到左1-9
            return chinese_numbers[8 - file];
        } else {
            // 黑方从左到右9-1
            return chinese_numbers[file];
        }
    }
    
    // 获取步数名称
    private string get_step_name(int steps) {
        string[] chinese_numbers = {"一", "二", "三", "四", "五", "六", "七", "八", "九"};
        if (steps >= 1 && steps <= 9) {
            return chinese_numbers[steps - 1];
        }
        return steps.to_string();
    }
}