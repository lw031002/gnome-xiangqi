/* xiangqi-game.vala
 *
 * 中国象棋游戏类
 */

public class XiangqiGame : Object {
    // 信号
    public signal void piece_moved (XiangqiPiece piece, int from_file, int from_rank, int to_file, int to_rank);
    public signal void piece_captured (XiangqiPiece piece);
    public signal void player_changed (XiangqiColor color);
    public signal void game_over (XiangqiColor? winner);
    public signal void check_occurred (XiangqiColor checked_color); // 将军信号
    
    // 游戏状态
    public XiangqiState state { get; private set; }
    
    // 历史记录
    public List<XiangqiMove> move_history = new List<XiangqiMove> ();
    
    // 选中的棋子
    public XiangqiPiece? selected_piece { get; set; default = null; }
    
    public XiangqiGame () {
        state = new XiangqiState ();
        state.game = this;
    }
    
    // 开始新游戏
    public void new_game () {
        state = new XiangqiState ();
        state.game = this;
        move_history = new List<XiangqiMove> ();
        selected_piece = null;
        player_changed (state.current_player);
    }
    
    // 尝试移动棋子
    public bool try_move (XiangqiPiece piece, int to_file, int to_rank) {
        // 检查是否轮到该棋子所属玩家
        if (piece.color != state.current_player) {
            return false;
        }
        
        // 创建移动对象
        var move = new XiangqiMove (piece, to_file, to_rank);
        
        // 检查移动是否合法
        if (!move.is_legal (state)) {
            return false;
        }
        
        // 执行移动
        return execute_move (move);
    }
    
    // 执行移动
    private bool execute_move (XiangqiMove move) {
        // 检查目标位置是否有对方棋子（吃子）
        var target_piece = state.get_piece_at (move.to_file, move.to_rank);
        if (target_piece != null) {
            // 吃子
            target_piece.captured = true;
            move.captured_piece = target_piece;
            piece_captured (target_piece);
        }
        
        // 记录原始位置
        int from_file = move.piece.file;
        int from_rank = move.piece.rank;
        
        // 更新棋子位置
        move.piece.file = move.to_file;
        move.piece.rank = move.to_rank;
        
        // 发送移动信号
        piece_moved (move.piece, from_file, from_rank, move.to_file, move.to_rank);
        
        // 添加到历史记录
        move_history.append (move);
        
        // 检查游戏是否结束
        if (check_game_over ()) {
            return true;
        }
        
        // 检查是否将军
        XiangqiColor? checked_color = is_in_check();
        if (checked_color != null) {
            check_occurred(checked_color);
        }
        
        // 切换玩家并发送信号
        state.switch_player ();
        player_changed (state.current_player);
        
        return true;
    }
    
    // 检查游戏是否结束
    private bool check_game_over () {
        // 检查将帅是否被吃掉
        bool red_general_exists = false;
        bool black_general_exists = false;
        XiangqiPiece? red_general = null;
        XiangqiPiece? black_general = null;
        
        foreach (var piece in state.pieces) {
            if (!piece.captured && piece.piece_type == XiangqiPieceType.GENERAL) {
                if (piece.color == XiangqiColor.RED) {
                    red_general_exists = true;
                    red_general = piece;
                } else {
                    black_general_exists = true;
                    black_general = piece;
                }
            }
        }
        
        if (!red_general_exists) {
            state.game_over = true;
            game_over (XiangqiColor.BLACK);
            return true;
        }
        
        if (!black_general_exists) {
            state.game_over = true;
            game_over (XiangqiColor.RED);
            return true;
        }
        
        // 检查将帅是否面对面（这是中国象棋的特殊规则）
        if (red_general != null && black_general != null && red_general.file == black_general.file) {
            // 检查两个将帅之间是否有其他棋子
            bool has_piece_between = false;
            int min_rank = int.min(red_general.rank, black_general.rank);
            int max_rank = int.max(red_general.rank, black_general.rank);
            
            for (int r = min_rank + 1; r < max_rank; r++) {
                if (state.get_piece_at(red_general.file, r) != null) {
                    has_piece_between = true;
                    break;
                }
            }
            
            if (!has_piece_between) {
                // 将帅面对面，当前玩家输
                state.game_over = true;
                game_over(state.current_player == XiangqiColor.RED ? XiangqiColor.BLACK : XiangqiColor.RED);
                return true;
            }
        }
        
        return false;
    }
    
    // 检查是否将军
    private XiangqiColor? is_in_check() {
        // 找到双方的将/帅
        XiangqiPiece? red_general = null;
        XiangqiPiece? black_general = null;
        
        foreach (var piece in state.pieces) {
            if (!piece.captured && piece.piece_type == XiangqiPieceType.GENERAL) {
                if (piece.color == XiangqiColor.RED) {
                    red_general = piece;
                } else {
                    black_general = piece;
                }
            }
        }
        
        if (red_general == null || black_general == null) {
            return null;
        }
        
        // 检查红方将军
        foreach (var piece in state.pieces) {
            if (!piece.captured && piece.color == XiangqiColor.RED) {
                var move = new XiangqiMove(piece, black_general.file, black_general.rank);
                if (move.is_legal(state)) {
                    return XiangqiColor.BLACK; // 黑方被将军
                }
            }
        }
        
        // 检查黑方将军
        foreach (var piece in state.pieces) {
            if (!piece.captured && piece.color == XiangqiColor.BLACK) {
                var move = new XiangqiMove(piece, red_general.file, red_general.rank);
                if (move.is_legal(state)) {
                    return XiangqiColor.RED; // 红方被将军
                }
            }
        }
        
        return null; // 没有将军
    }
    
    // 悔棋
    public bool undo_move () {
        if (move_history.length () == 0) {
            return false;
        }
        
        // 获取最后一步
        var last_move = move_history.last ().data;
        move_history.remove (last_move);
        
        // 恢复棋子位置
        last_move.piece.file = last_move.from_file;
        last_move.piece.rank = last_move.from_rank;
        
        // 恢复被吃的棋子
        if (last_move.captured_piece != null) {
            last_move.captured_piece.captured = false;
        }
        
        // 切换玩家
        state.switch_player ();
        player_changed (state.current_player);
        
        // 发送移动信号（反向）
        piece_moved (last_move.piece, last_move.to_file, last_move.to_rank, last_move.from_file, last_move.from_rank);
        
        return true;
    }
}