/* xiangqi-view.vala
 *
 * 中国象棋视图类
 */

public class XiangqiView : Gtk.DrawingArea {
    // 游戏对象
    public XiangqiGame game { get; set; }
    
    // 场景对象
    private XiangqiScene scene;
    
    // 选中的棋子
    private XiangqiPiece? selected_piece = null;
    
    // 鼠标位置
    private double mouse_x = 0;
    private double mouse_y = 0;
    
    // 棋盘尺寸
    private int board_size = 0;
    private int square_size = 0;
    private int piece_size = 0;
    private int board_x_offset = 0;
    private int board_y_offset = 0;
    
    public XiangqiView () {
        Object ();
        
        // 设置可以接收鼠标事件
        set_can_focus (true);
        set_focusable (true);
        
        // 创建场景
        scene = new XiangqiScene ();
        
        // 设置绘制回调
        set_draw_func (draw);
        
        // 添加鼠标事件处理
        var click_controller = new Gtk.GestureClick ();
        click_controller.set_button (1); // 左键
        click_controller.pressed.connect (on_button_pressed);
        click_controller.released.connect (on_button_released);
        add_controller (click_controller);
        
        var motion_controller = new Gtk.EventControllerMotion ();
        motion_controller.motion.connect (on_motion);
        add_controller (motion_controller);
    }
    
    // 构造函数中设置游戏对象
    public void initialize_game (XiangqiGame game) {
        this.game = game;
        
        // 连接信号
        game.piece_moved.connect (on_piece_moved);
        game.piece_captured.connect (on_piece_captured);
        game.player_changed.connect (on_player_changed);
        game.game_over.connect (on_game_over);
        
        // 更新场景 - 确保使用同一个状态对象
        scene.set_state (game.state);
        
        // 重绘
        queue_draw ();
    }
    
    // 更新游戏状态（用于新游戏时同步状态）
    public void update_game_state () {
        if (game != null) {
            scene.set_state (game.state);
            queue_draw ();
        }
    }
    
    // 设置临时状态（用于查看历史记录）
    public void set_temporary_state (XiangqiState state) {
        scene.set_state (state);
        queue_draw ();
    }
    
    // 恢复到当前游戏状态
    public void restore_current_state () {
        if (game != null) {
            scene.set_state (game.state);
            queue_draw ();
        }
    }
    
    // 绘制回调
    private void draw (Gtk.DrawingArea area, Cairo.Context cr, int width, int height) {
        // 计算棋盘尺寸
        calculate_board_size (width, height);
        
        // 绘制场景
        scene.draw (cr, board_x_offset, board_y_offset, board_size, square_size, piece_size);
        
        // 不再在这里绘制选中效果，而是在scene.draw_pieces中处理
    }
    
    // 计算棋盘尺寸
    private void calculate_board_size (int width, int height) {
        // 计算棋盘大小，保持9:10的比例
        int max_width = width - 40;
        int max_height = height - 40;
        
        int potential_width = max_height * 9 / 10;
        int potential_height = max_width * 10 / 9;
        
        if (potential_width <= max_width) {
            board_size = potential_width;
        } else {
            board_size = max_width;
        }
        
        // 计算格子大小
        square_size = board_size / 9;
        board_size = square_size * 9; // 调整为精确的9倍
        
        // 计算棋子大小
        piece_size = (int)(square_size * 0.9);
        
        // 计算偏移量，使棋盘居中
        board_x_offset = (width - board_size) / 2;
        board_y_offset = (height - (square_size * 10)) / 2;
    }
    
    // 将屏幕坐标转换为棋盘坐标（交叉点）
    private bool screen_to_board (double x, double y, out int file, out int rank) {
        // 计算相对于棋盘左上角的坐标，考虑到棋盘的实际偏移
        double rel_x = x - board_x_offset - square_size / 2;
        double rel_y = y - board_y_offset - square_size / 2;
        
        // 计算最近的交叉点
        double file_exact = rel_x / square_size;
        double rank_exact = rel_y / square_size;
        
        // 四舍五入到最近的整数
        file = (int)Math.round(file_exact);
        rank = (int)Math.round(rank_exact);
        
        // 检查是否在棋盘范围内
        return file >= 0 && file < 9 && rank >= 0 && rank < 10;
    }
    
    // 检查点击是否在棋子上
    private XiangqiPiece? get_piece_at_position(double x, double y) {
        if (game == null || game.state == null) {
            return null;
        }
        
        // 设置一个合理的距离阈值，使选择更容易
        double threshold = piece_size * 0.6;
        XiangqiPiece? closest_piece = null;
        double min_distance = threshold;
        
        // 遍历所有棋子，找到最近的一个
        foreach (var p in game.state.pieces) {
            if (p.captured) {
                continue;
            }
            
            // 计算点击位置到棋子中心的距离，与场景绘制保持一致
            // 考虑到场景中的偏移量调整
            double piece_center_x = board_x_offset + square_size / 2 + p.file * square_size;
            double piece_center_y = board_y_offset + square_size / 2 + p.rank * square_size;
            double distance = Math.sqrt(Math.pow(x - piece_center_x, 2) + Math.pow(y - piece_center_y, 2));
            
            // 如果距离小于阈值且比之前找到的棋子更近
            if (distance < min_distance) {
                min_distance = distance;
                closest_piece = p;
            }
        }
        
        return closest_piece;
    }
    
    // 鼠标按下事件
    private void on_button_pressed (int n_press, double x, double y) {
        // 使用精准选中功能获取棋子
        var piece = get_piece_at_position(x, y);
        
        // 如果已经有选中的棋子，并且点击了同一个棋子，则取消选中
        if (selected_piece != null && piece == selected_piece) {
            selected_piece = null;
            game.selected_piece = null;
            queue_draw();
            return;
        }
        
        // 如果有棋子且是当前玩家的棋子
        if (piece != null && piece.color == game.state.current_player) {
            selected_piece = piece;
            game.selected_piece = piece;
            queue_draw();
        } else if (selected_piece != null) {
            // 如果已有选中的棋子
            if (piece != null && piece.color != game.state.current_player) {
                // 如果点击了对方棋子，尝试吃子
                int file = piece.file;
                int rank = piece.rank;
                if (game.try_move(selected_piece, file, rank)) {
                    // 吃子成功，清除选中状态
                    selected_piece = null;
                    game.selected_piece = null;
                    queue_draw();
                    return;
                }
            } else if (piece == null) {
                // 如果点击了空白区域，尝试移动
                int file, rank;
                if (screen_to_board(x, y, out file, out rank)) {
                    if (game.try_move(selected_piece, file, rank)) {
                        // 移动成功，清除选中状态
                        selected_piece = null;
                        game.selected_piece = null;
                        queue_draw();
                        return;
                    }
                }
            }
            
            // 如果移动失败或点击在棋盘外，取消选中
            selected_piece = null;
            game.selected_piece = null;
            queue_draw();
        }
    }
    
    // 鼠标释放事件
    private void on_button_released (int n_press, double x, double y) {
        // 在按下事件中已经处理了所有逻辑，这里不需要额外操作
    }
    
    // 鼠标移动事件
    private void on_motion (double x, double y) {
        mouse_x = x;
        mouse_y = y;
    }
    
    // 棋子移动事件处理
    private void on_piece_moved (XiangqiPiece piece, int from_file, int from_rank, int to_file, int to_rank) {
        queue_draw ();
    }
    
    // 棋子被吃事件处理
    private void on_piece_captured (XiangqiPiece piece) {
        queue_draw ();
    }
    
    // 玩家变更事件处理
    private void on_player_changed (XiangqiColor color) {
        queue_draw ();
    }
    
    // 游戏结束事件处理
    private void on_game_over (XiangqiColor? winner) {
        queue_draw ();
    }
}