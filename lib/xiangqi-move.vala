/* xiangqi-move.vala
 *
 * 中国象棋走子类
 */

public class XiangqiMove : Object {
    public XiangqiPiece piece { get; private set; }
    public int from_file { get; private set; }
    public int from_rank { get; private set; }
    public int to_file { get; private set; }
    public int to_rank { get; private set; }
    public XiangqiPiece? captured_piece { get; set; default = null; }
    
    public XiangqiMove (XiangqiPiece piece, int to_file, int to_rank) {
        this.piece = piece;
        this.from_file = piece.file;
        this.from_rank = piece.rank;
        this.to_file = to_file;
        this.to_rank = to_rank;
    }
    
    // 获取移动的描述（如：炮二平五、马8进7等）
    public string get_move_description ()
    {
        // 获取棋子名称
        string piece_name = "";
        switch (piece.piece_type) {
            case XiangqiPieceType.GENERAL:
                piece_name = (piece.color == XiangqiColor.RED) ? "帅" : "将";
                break;
            case XiangqiPieceType.ADVISOR:
                piece_name = (piece.color == XiangqiColor.RED) ? "仕" : "士";
                break;
            case XiangqiPieceType.ELEPHANT:
                piece_name = (piece.color == XiangqiColor.RED) ? "相" : "象";
                break;
            case XiangqiPieceType.HORSE:
                piece_name = "马";
                break;
            case XiangqiPieceType.CHARIOT:
                piece_name = "车";
                break;
            case XiangqiPieceType.CANNON:
                piece_name = "炮";
                break;
            case XiangqiPieceType.SOLDIER:
                piece_name = (piece.color == XiangqiColor.RED) ? "兵" : "卒";
                break;
        }
        
        // 获取棋子位置编号
        string position = "";
        if (piece.color == XiangqiColor.RED) {
            // 红方使用汉字表示列
            string[] file_names = {"九", "八", "七", "六", "五", "四", "三", "二", "一"};
            position = file_names[from_file];
        } else {
            // 黑方使用数字表示列
            position = (from_file + 1).to_string();
        }
        
        // 获取移动方向
        string direction = "";
        if (from_file == to_file) {
            // 纵向移动
            if ((piece.color == XiangqiColor.RED && to_rank < from_rank) || 
                (piece.color == XiangqiColor.BLACK && to_rank > from_rank)) {
                direction = "进";
            } else {
                direction = "退";
            }
            // 移动的格数
            int steps = (to_rank - from_rank).abs();
            if (piece.color == XiangqiColor.RED) {
                string[] step_names = {"一", "二", "三", "四", "五", "六", "七", "八", "九"};
                direction += step_names[steps - 1];
            } else {
                direction += steps.to_string();
            }
        } else {
            // 横向移动
            direction = "平";
            if (piece.color == XiangqiColor.RED) {
                // 红方使用汉字表示列
                string[] file_names = {"九", "八", "七", "六", "五", "四", "三", "二", "一"};
                direction += file_names[to_file];
            } else {
                // 黑方使用数字表示列
                direction += (to_file + 1).to_string();
            }
        }
        
        return piece_name + position + direction;
    }
    
    // 检查移动是否合法
    public bool is_legal (XiangqiState state) {
        // 基本检查：目标位置在棋盘内
        if (to_file < 0 || to_file >= XiangqiState.FILES || to_rank < 0 || to_rank >= XiangqiState.RANKS) {
            return false;
        }
        
        // 检查目标位置是否有己方棋子
        var target_piece = state.get_piece_at (to_file, to_rank);
        if (target_piece != null && target_piece.color == piece.color) {
            return false;
        }
        
        // 如果起点和终点相同，不是合法移动
        if (from_file == to_file && from_rank == to_rank) {
            return false;
        }
        
        // 根据棋子类型检查移动规则
        switch (piece.piece_type) {
            case XiangqiPieceType.GENERAL:
                return is_legal_general_move (state);
            case XiangqiPieceType.ADVISOR:
                return is_legal_advisor_move (state);
            case XiangqiPieceType.ELEPHANT:
                return is_legal_elephant_move (state);
            case XiangqiPieceType.HORSE:
                return is_legal_horse_move (state);
            case XiangqiPieceType.CHARIOT:
                return is_legal_chariot_move (state);
            case XiangqiPieceType.CANNON:
                return is_legal_cannon_move (state);
            case XiangqiPieceType.SOLDIER:
                return is_legal_soldier_move (state);
            default:
                return false;
        }
    }
    
    // 将/帅移动规则
    private bool is_legal_general_move (XiangqiState state) {
        // 只能在九宫格内移动
        if (piece.color == XiangqiColor.RED) {
            // 红方九宫格
            if (to_file < 3 || to_file > 5 || to_rank < 7 || to_rank > 9) {
                return false;
            }
        } else {
            // 黑方九宫格
            if (to_file < 3 || to_file > 5 || to_rank < 0 || to_rank > 2) {
                return false;
            }
        }
        
        // 只能横向或纵向移动一格
        int file_diff = (to_file - from_file).abs ();
        int rank_diff = (to_rank - from_rank).abs ();
        
        return (file_diff == 1 && rank_diff == 0) || (file_diff == 0 && rank_diff == 1);
    }
    
    // 士/仕移动规则
    private bool is_legal_advisor_move (XiangqiState state) {
        // 只能在九宫格内移动
        if (piece.color == XiangqiColor.RED) {
            // 红方九宫格
            if (to_file < 3 || to_file > 5 || to_rank < 7 || to_rank > 9) {
                return false;
            }
        } else {
            // 黑方九宫格
            if (to_file < 3 || to_file > 5 || to_rank < 0 || to_rank > 2) {
                return false;
            }
        }
        
        // 只能斜着走一格
        int file_diff = (to_file - from_file).abs ();
        int rank_diff = (to_rank - from_rank).abs ();
        
        return file_diff == 1 && rank_diff == 1;
    }
    
    // 象/相移动规则
    private bool is_legal_elephant_move (XiangqiState state) {
        // 不能过河
        if (piece.color == XiangqiColor.RED && to_rank < 5) {
            return false;
        }
        if (piece.color == XiangqiColor.BLACK && to_rank > 4) {
            return false;
        }
        
        // 只能走"田"字
        int file_diff = (to_file - from_file).abs ();
        int rank_diff = (to_rank - from_rank).abs ();
        
        if (file_diff != 2 || rank_diff != 2) {
            return false;
        }
        
        // 检查象眼是否被塞住
        int eye_file = (from_file + to_file) / 2;
        int eye_rank = (from_rank + to_rank) / 2;
        
        return state.get_piece_at (eye_file, eye_rank) == null;
    }
    
    // 马移动规则
    private bool is_legal_horse_move (XiangqiState state) {
        int file_diff = (to_file - from_file).abs ();
        int rank_diff = (to_rank - from_rank).abs ();
        
        // 马走"日"字
        if (!((file_diff == 1 && rank_diff == 2) || (file_diff == 2 && rank_diff == 1))) {
            return false;
        }
        
        // 检查马腿是否被塞住
        int leg_file = from_file;
        int leg_rank = from_rank;
        
        if (file_diff == 2) {
            // 横向移动，检查横向马腿
            leg_file = from_file + ((to_file > from_file) ? 1 : -1);
        } else {
            // 纵向移动，检查纵向马腿
            leg_rank = from_rank + ((to_rank > from_rank) ? 1 : -1);
        }
        
        return state.get_piece_at (leg_file, leg_rank) == null;
    }
    
    // 车移动规则
    private bool is_legal_chariot_move (XiangqiState state) {
        int file_diff = (to_file - from_file).abs ();
        int rank_diff = (to_rank - from_rank).abs ();
        
        // 只能横向或纵向移动
        if (file_diff != 0 && rank_diff != 0) {
            return false;
        }
        
        // 检查路径上是否有其他棋子
        if (file_diff > 0) {
            // 横向移动
            int step = (to_file > from_file) ? 1 : -1;
            for (int f = from_file + step; f != to_file; f += step) {
                if (state.get_piece_at (f, from_rank) != null) {
                    return false;
                }
            }
        } else if (rank_diff > 0) {
            // 纵向移动
            int step = (to_rank > from_rank) ? 1 : -1;
            for (int r = from_rank + step; r != to_rank; r += step) {
                if (state.get_piece_at (from_file, r) != null) {
                    return false;
                }
            }
        }
        
        return true;
    }
    
    // 炮移动规则
    private bool is_legal_cannon_move (XiangqiState state) {
        int file_diff = (to_file - from_file).abs ();
        int rank_diff = (to_rank - from_rank).abs ();
        
        // 只能横向或纵向移动
        if (file_diff != 0 && rank_diff != 0) {
            return false;
        }
        
        // 目标位置有棋子（吃子）
        var target_piece = state.get_piece_at (to_file, to_rank);
        if (target_piece != null) {
            // 吃子时需要有且仅有一个炮台
            int cannon_mount_count = 0;
            
            if (file_diff > 0) {
                // 横向移动
                int step = (to_file > from_file) ? 1 : -1;
                for (int f = from_file + step; f != to_file; f += step) {
                    if (state.get_piece_at (f, from_rank) != null) {
                        cannon_mount_count++;
                    }
                }
            } else if (rank_diff > 0) {
                // 纵向移动
                int step = (to_rank > from_rank) ? 1 : -1;
                for (int r = from_rank + step; r != to_rank; r += step) {
                    if (state.get_piece_at (from_file, r) != null) {
                        cannon_mount_count++;
                    }
                }
            }
            
            return cannon_mount_count == 1;
        } else {
            // 移动时路径上不能有棋子
            if (file_diff > 0) {
                // 横向移动
                int step = (to_file > from_file) ? 1 : -1;
                for (int f = from_file + step; f != to_file; f += step) {
                    if (state.get_piece_at (f, from_rank) != null) {
                        return false;
                    }
                }
            } else if (rank_diff > 0) {
                // 纵向移动
                int step = (to_rank > from_rank) ? 1 : -1;
                for (int r = from_rank + step; r != to_rank; r += step) {
                    if (state.get_piece_at (from_file, r) != null) {
                        return false;
                    }
                }
            }
            
            return true;
        }
    }
    
    // 兵/卒移动规则
    private bool is_legal_soldier_move (XiangqiState state) {
        int file_diff = (to_file - from_file).abs ();
        int rank_diff = (to_rank - from_rank).abs ();
        
        // 只能移动一格
        if (file_diff > 1 || rank_diff > 1 || (file_diff == 1 && rank_diff == 1)) {
            return false;
        }
        
        if (piece.color == XiangqiColor.RED) {
            // 红方兵（在下方，向上移动，rank减小）
            if (from_rank >= 5) {
                // 未过河，只能向前移动（向上，rank减小）
                return to_file == from_file && to_rank == from_rank - 1;
            } else {
                // 已过河，可以向前或横向移动
                if (to_rank == from_rank - 1 && to_file == from_file) {
                    return true; // 向前（向上）
                }
                if (to_rank == from_rank && (to_file == from_file - 1 || to_file == from_file + 1)) {
                    return true; // 横向
                }
                return false;
            }
        } else {
            // 黑方卒（在上方，向下移动，rank增大）
            if (from_rank <= 4) {
                // 未过河，只能向前移动（向下，rank增大）
                return to_file == from_file && to_rank == from_rank + 1;
            } else {
                // 已过河，可以向前或横向移动
                if (to_rank == from_rank + 1 && to_file == from_file) {
                    return true; // 向前（向下）
                }
                if (to_rank == from_rank && (to_file == from_file - 1 || to_file == from_file + 1)) {
                    return true; // 横向
                }
                return false;
            }
        }
    }
}