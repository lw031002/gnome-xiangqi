/* xiangqi-scene.vala
 *
 * 中国象棋场景类
 */

public class XiangqiScene : Object {
    // 棋盘状态
    private XiangqiState state;
    
    // 棋子图像缓存
    private Cairo.Surface[,] piece_surfaces;
    
    public XiangqiScene () {
        // 初始化棋子图像缓存
        piece_surfaces = new Cairo.Surface[2, 7]; // [颜色, 类型]
    }
    
    // 设置棋盘状态
    // 设置棋盘状态
    public void set_state (XiangqiState state) {
        this.state = state;
    }
    
    // 绘制场景
    public void draw (Cairo.Context cr, int x_offset, int y_offset, int board_size, int square_size, int piece_size) {
        // 调整偏移量，使棋盘四周完全对称
        int adjusted_x_offset = x_offset + square_size / 2;
        int adjusted_y_offset = y_offset + square_size / 2;
        
        // 计算实际棋盘大小
        int actual_board_width = 8 * square_size;
        int actual_board_height = 9 * square_size;
        
        // 绘制棋盘背景
        draw_board_background (cr, adjusted_x_offset, adjusted_y_offset, actual_board_width, square_size);
        
        // 绘制棋盘背景
        draw_board_background (cr, adjusted_x_offset, adjusted_y_offset, actual_board_width, square_size);
        
        // 绘制棋盘网格
        draw_board_grid (cr, adjusted_x_offset, adjusted_y_offset, square_size);
        
        // 绘制九宫格
        draw_palace (cr, adjusted_x_offset, adjusted_y_offset, square_size);
        
        // 绘制楚河汉界
        draw_river (cr, adjusted_x_offset, adjusted_y_offset, square_size);
        
        // 绘制棋子
        draw_pieces (cr, adjusted_x_offset, adjusted_y_offset, square_size, piece_size);
    }
    
    
    // 绘制棋盘背景
    private void draw_board_background (Cairo.Context cr, int x_offset, int y_offset, int board_size, int square_size) {
        // 绘制背景
        cr.save ();
        
        // 确保背景完全对称
        int total_width = board_size + square_size;
        int total_height = 9 * square_size + square_size;
        
        // 绘制主背景
        cr.rectangle (x_offset - square_size/2, y_offset - square_size/2, 
                     total_width, total_height);
                     
        // 使用更传统的棋盘背景色
        cr.set_source_rgb (0.93, 0.82, 0.6); // 浅木色
        cr.fill ();
        
        // 添加木纹效果
        cr.set_source_rgba (0.7, 0.6, 0.4, 0.05);
        for (int i = 0; i < 50; i++) {
            double x1 = x_offset - square_size/2 + Random.double_range(0, total_width);
            double y1 = y_offset - square_size/2;
            double x2 = x1 + Random.double_range(-square_size/2, square_size/2);
            double y2 = y_offset - square_size/2 + total_height;
            
            cr.move_to(x1, y1);
            cr.line_to(x2, y2);
            cr.set_line_width(Random.double_range(0.5, 2.0));
            cr.stroke();
        }
        
        cr.restore ();
    }
    
    // 绘制棋盘网格
    private void draw_board_grid (Cairo.Context cr, int x_offset, int y_offset, int square_size) {
        cr.save ();
        cr.set_source_rgba (0.0, 0.0, 0.0, 0.8); // 更深的黑色
        cr.set_line_width (3.0); // 统一使用加粗线宽
        
        // 绘制外框 - 双线
        // 外线
        cr.rectangle (x_offset - 5, y_offset - 5, 8 * square_size + 10, 9 * square_size + 10);
        cr.stroke ();
        
        // 内线
        cr.rectangle (x_offset, y_offset, 8 * square_size, 9 * square_size);
        cr.stroke ();
        
        // 绘制内部横线 - 使用统一线宽
        for (int i = 1; i < 9; i++) {
            int y = y_offset + i * square_size;
            cr.move_to (x_offset, y);
            cr.line_to (x_offset + 8 * square_size, y);
            cr.stroke ();
        }
        
        // 绘制内部竖线 - 使用统一线宽
        for (int i = 1; i < 8; i++) {
            int x = x_offset + i * square_size;
            
            // 上半部分
            cr.move_to (x, y_offset);
            cr.line_to (x, y_offset + 4 * square_size);
            cr.stroke ();
            
            // 下半部分
            cr.move_to (x, y_offset + 5 * square_size);
            cr.line_to (x, y_offset + 9 * square_size);
            cr.stroke ();
        }
        
        // 绘制兵位标记
        draw_position_marks(cr, x_offset, y_offset, square_size);
        
        cr.restore ();
    }
    
    // 绘制兵位和炮位标记
    private void draw_position_marks(Cairo.Context cr, int x_offset, int y_offset, int square_size) {
        cr.set_line_width (3.0); // 统一使用加粗线宽
        
        // 兵位标记点的大小
        int mark_size = square_size / 10;
        
        // 绘制黑方兵位标记
        draw_position_mark(cr, x_offset + 0 * square_size, y_offset + 3 * square_size, mark_size);
        draw_position_mark(cr, x_offset + 2 * square_size, y_offset + 3 * square_size, mark_size);
        draw_position_mark(cr, x_offset + 4 * square_size, y_offset + 3 * square_size, mark_size);
        draw_position_mark(cr, x_offset + 6 * square_size, y_offset + 3 * square_size, mark_size);
        draw_position_mark(cr, x_offset + 8 * square_size, y_offset + 3 * square_size, mark_size);
        
        // 绘制红方兵位标记
        draw_position_mark(cr, x_offset + 0 * square_size, y_offset + 6 * square_size, mark_size);
        draw_position_mark(cr, x_offset + 2 * square_size, y_offset + 6 * square_size, mark_size);
        draw_position_mark(cr, x_offset + 4 * square_size, y_offset + 6 * square_size, mark_size);
        draw_position_mark(cr, x_offset + 6 * square_size, y_offset + 6 * square_size, mark_size);
        draw_position_mark(cr, x_offset + 8 * square_size, y_offset + 6 * square_size, mark_size);
        
        // 绘制黑方炮位标记
        draw_position_mark(cr, x_offset + 1 * square_size, y_offset + 2 * square_size, mark_size);
        draw_position_mark(cr, x_offset + 7 * square_size, y_offset + 2 * square_size, mark_size);
        
        // 绘制红方炮位标记
        draw_position_mark(cr, x_offset + 1 * square_size, y_offset + 7 * square_size, mark_size);
        draw_position_mark(cr, x_offset + 7 * square_size, y_offset + 7 * square_size, mark_size);
    }
    
    // 绘制单个标记点
    private void draw_position_mark(Cairo.Context cr, int x, int y, int size) {
        // 绘制十字标记，保持线宽一致
        cr.move_to(x - size, y);
        cr.line_to(x + size, y);
        cr.stroke();
        
        cr.move_to(x, y - size);
        cr.line_to(x, y + size);
        cr.stroke();
    }
    
    // 绘制九宫格
    private void draw_palace (Cairo.Context cr, int x_offset, int y_offset, int square_size) {
        cr.save ();
        cr.set_source_rgb (0.0, 0.0, 0.0);
        cr.set_line_width (1.0);
        
        // 上方九宫格对角线
        cr.move_to (x_offset + 3 * square_size, y_offset);
        cr.line_to (x_offset + 5 * square_size, y_offset + 2 * square_size);
        cr.stroke ();
        
        cr.move_to (x_offset + 5 * square_size, y_offset);
        cr.line_to (x_offset + 3 * square_size, y_offset + 2 * square_size);
        cr.stroke ();
        
        // 下方九宫格对角线
        cr.move_to (x_offset + 3 * square_size, y_offset + 7 * square_size);
        cr.line_to (x_offset + 5 * square_size, y_offset + 9 * square_size);
        cr.stroke ();
        
        cr.move_to (x_offset + 5 * square_size, y_offset + 7 * square_size);
        cr.line_to (x_offset + 3 * square_size, y_offset + 9 * square_size);
        cr.stroke ();
        
        cr.restore ();
    }
    
    // 绘制楚河汉界
    private void draw_river (Cairo.Context cr, int x_offset, int y_offset, int square_size) {
        cr.save ();
        
        // 绘制背景 
        cr.set_line_width (3.0); // 加粗边框
        cr.rectangle (x_offset, y_offset + 4 * square_size, 8 * square_size, square_size);
        cr.stroke(); // 先绘制边框
        
        // 重新绘制矩形用于填充
        cr.rectangle (x_offset, y_offset + 4 * square_size, 8 * square_size, square_size);
        
        // 使用更柔和的渐变效果
        var pattern = new Cairo.Pattern.linear (
            x_offset, y_offset + 4.5 * square_size,
            x_offset + 8 * square_size, y_offset + 4.5 * square_size
        );
        pattern.add_color_stop_rgba (0, 0.9, 0.95, 1.0, 0.1); // 非常浅的蓝色，更透明
        pattern.add_color_stop_rgba (0.5, 0.85, 0.9, 0.95, 0.08); // 中间色，更透明
        pattern.add_color_stop_rgba (1, 0.9, 0.95, 1.0, 0.1); // 非常浅的蓝色，更透明
        cr.set_source (pattern);
        cr.fill ();
        
        // 绘制文字 - 使用更柔和的颜色
        cr.select_font_face ("Noto Sans CJK SC", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
        cr.set_font_size (square_size * 0.5); // 稍微小一点的字体
        cr.set_source_rgba (0.3, 0.3, 0.5, 0.7); // 柔和的深蓝色文字，半透明
        
        // 楚河 - 精确计算位置
        Cairo.TextExtents extents;
        cr.text_extents ("楚河", out extents);
        cr.move_to (x_offset + 2 * square_size - extents.width / 2, 
                   y_offset + 4.5 * square_size + extents.height / 3);
        cr.show_text ("楚河");
        
        // 汉界 - 精确计算位置
        cr.text_extents ("汉界", out extents);
        cr.move_to (x_offset + 6 * square_size - extents.width / 2, 
                   y_offset + 4.5 * square_size + extents.height / 3);
        cr.show_text ("汉界");
        
        cr.restore ();
    }
    
    // 绘制可走路线
    public void draw_possible_moves(Cairo.Context cr, int x_offset, int y_offset, int square_size, XiangqiPiece selected_piece) {
        if (state == null || selected_piece == null || state.game == null) {
            return;
        }
        
        // 遍历棋盘上所有可能的位置
        for (int file = 0; file < XiangqiState.FILES; file++) {
            for (int rank = 0; rank < XiangqiState.RANKS; rank++) {
                // 跳过当前棋子位置
                if (file == selected_piece.file && rank == selected_piece.rank) {
                    continue;
                }
                
                // 创建移动对象并检查是否合法
                var move = new XiangqiMove(selected_piece, file, rank);
                if (move.is_legal(state)) {
                    // 绘制可走路线标记
                    int x = x_offset + file * square_size;
                    int y = y_offset + rank * square_size;
                    
                    // 检查目标位置是否有对方棋子
                    var target_piece = state.get_piece_at(file, rank);
                    if (target_piece != null && target_piece.color != selected_piece.color) {
                        // 可以吃子的位置用红色标记
                        cr.save();
                        cr.arc(x, y, square_size / 5, 0, 2 * Math.PI);
                        cr.set_source_rgba(0.9, 0.2, 0.2, 0.6); // 半透明红色
                        cr.fill();
                        cr.restore();
                    } else {
                        // 可以移动的位置用灰色标记
                        cr.save();
                        cr.arc(x, y, square_size / 5, 0, 2 * Math.PI);
                        cr.set_source_rgba(0.5, 0.5, 0.5, 0.6); // 半透明灰色
                        cr.fill();
                        cr.restore();
                    }
                }
            }
        }
    }
    
    // 绘制棋子
    private void draw_pieces (Cairo.Context cr, int x_offset, int y_offset, int square_size, int piece_size) {
        if (state == null) {
            return;
        }
        
        // 获取选中的棋子
        XiangqiPiece? selected_piece = null;
        if (state.game != null) {
            selected_piece = state.game.selected_piece;
        }
        
        // 先绘制可走路线
        if (selected_piece != null) {
            draw_possible_moves(cr, x_offset, y_offset, square_size, selected_piece);
        }
        
        // 找到将/帅棋子，用于将军提示
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
        
        // 先绘制未选中的棋子
        foreach (var piece in state.pieces) {
            if (piece.captured || piece == selected_piece) {
                continue;
            }
            
            // 棋子应该放在交叉点上，而不是格子中间
            int x = x_offset + piece.file * square_size - piece_size / 2;
            int y = y_offset + piece.rank * square_size - piece_size / 2;
            
            // 检查是否是被将军的将/帅
            bool is_in_check = false;
            
            // 如果是将/帅，检查是否被将军
            if (piece.piece_type == XiangqiPieceType.GENERAL) {
                // 检查对方棋子是否可以吃掉这个将/帅
                foreach (var opponent_piece in state.pieces) {
                    if (!opponent_piece.captured && opponent_piece.color != piece.color) {
                        var move = new XiangqiMove(opponent_piece, piece.file, piece.rank);
                        if (move.is_legal(state)) {
                            is_in_check = true;
                            break;
                        }
                    }
                }
            }
            
            // 绘制棋子
            draw_single_piece(cr, piece, x, y, piece_size);
            
            // 如果是被将军的将/帅，绘制将军提示效果
            if (is_in_check) {
                // 绘制将军提示效果（红色闪烁边框）
                cr.save();
                cr.set_source_rgba(0.9, 0.1, 0.1, 0.8); // 鲜红色
                cr.set_line_width(3.0);
                cr.arc(x + piece_size / 2, y + piece_size / 2, piece_size / 2 + 3, 0, 2 * Math.PI);
                cr.stroke();
                
                // 添加第二个闪烁边框
                cr.set_source_rgba(1.0, 0.3, 0.3, 0.5); // 半透明红色
                cr.set_line_width(2.0);
                cr.arc(x + piece_size / 2, y + piece_size / 2, piece_size / 2 + 6, 0, 2 * Math.PI);
                cr.stroke();
                cr.restore();
            }
        }
        
        // 最后绘制选中的棋子（确保它在最上层）
        if (selected_piece != null && !selected_piece.captured) {
            // 放大选中的棋子
            int enlarged_size = (int)(piece_size * 1.3);
            int x = x_offset + selected_piece.file * square_size - enlarged_size / 2;
            int y = y_offset + selected_piece.rank * square_size - enlarged_size / 2;
            
            // 绘制光晕效果
            cr.save();
            cr.arc(x_offset + selected_piece.file * square_size, 
                  y_offset + selected_piece.rank * square_size, 
                  enlarged_size / 2 + 2, 0, 2 * Math.PI);
            cr.set_source_rgba(1.0, 0.8, 0.0, 0.5); // 半透明金黄色
            cr.fill();
            cr.restore();
            
            // 绘制放大的棋子
            draw_single_piece(cr, selected_piece, x, y, enlarged_size);
        }
    }
    
    // 绘制单个棋子
    private void draw_single_piece(Cairo.Context cr, XiangqiPiece piece, int x, int y, int size) {
        cr.save();
        
        // 绘制棋子背景 - 纯色无边框
        cr.arc (x + size / 2, y + size / 2, size / 2 - 1, 0, 2 * Math.PI);
        
        // 棋子颜色 - 纯黑和深红
        if (piece.color == XiangqiColor.RED) {
            // 红方棋子 - 深红色
            cr.set_source_rgb (0.8, 0.0, 0.0); // 深红色
        } else {
            // 黑方棋子 - 纯黑色
            cr.set_source_rgb (0.0, 0.0, 0.0); // 纯黑色
        }
        
        cr.fill ();
        cr.restore ();
        
        // 绘制棋子文字
        cr.save ();
        cr.select_font_face ("Noto Sans CJK SC", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
        cr.set_font_size (size * 0.5);
        
        string text = "";
        switch (piece.piece_type) {
            case XiangqiPieceType.GENERAL:
                text = (piece.color == XiangqiColor.RED) ? "帅" : "将";
                break;
            case XiangqiPieceType.ADVISOR:
                text = (piece.color == XiangqiColor.RED) ? "仕" : "士";
                break;
            case XiangqiPieceType.ELEPHANT:
                text = (piece.color == XiangqiColor.RED) ? "相" : "象";
                break;
            case XiangqiPieceType.HORSE:
                text = "马";
                break;
            case XiangqiPieceType.CHARIOT:
                text = "车";
                break;
            case XiangqiPieceType.CANNON:
                text = "炮";
                break;
            case XiangqiPieceType.SOLDIER:
                text = (piece.color == XiangqiColor.RED) ? "兵" : "卒";
                break;
        }
        
        // 设置文字颜色 - 白色文字
        cr.set_source_rgb (1.0, 1.0, 1.0); // 纯白色文字
        
        // 精确计算文字位置以确保居中
        Cairo.TextExtents extents;
        cr.text_extents (text, out extents);
        double text_x = x + size / 2 - (extents.width / 2 + extents.x_bearing);
        double text_y = y + size / 2 - (extents.height / 2 + extents.y_bearing);
        
        // 绘制主文字
        cr.move_to (text_x, text_y);
        cr.show_text (text);
        
        cr.restore ();
    }
}