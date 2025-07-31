/* xiangqi-state.vala
 *
 * 中国象棋棋盘状态类
 */

public class XiangqiState : Object {
    // 棋盘尺寸
    public const int FILES = 9;  // 列数
    public const int RANKS = 10; // 行数
    
    // 棋子列表
    public List<XiangqiPiece> pieces = new List<XiangqiPiece> ();
    
    // 当前走子方
    public XiangqiColor current_player { get; set; default = XiangqiColor.RED; }
    
    // 游戏状态
    public bool game_over { get; set; default = false; }
    
    // 游戏对象引用
    public XiangqiGame? game { get; set; default = null; }
    
    public XiangqiState () {
        setup_pieces ();
    }
    
    // 设置初始棋盘
    private void setup_pieces () {
        // 清空棋子列表
        pieces = new List<XiangqiPiece> ();
        
        // 红方（下方）棋子
        // 帅
        pieces.append (new XiangqiPiece (XiangqiPieceType.GENERAL, XiangqiColor.RED, 4, 9));
        // 仕
        pieces.append (new XiangqiPiece (XiangqiPieceType.ADVISOR, XiangqiColor.RED, 3, 9));
        pieces.append (new XiangqiPiece (XiangqiPieceType.ADVISOR, XiangqiColor.RED, 5, 9));
        // 相
        pieces.append (new XiangqiPiece (XiangqiPieceType.ELEPHANT, XiangqiColor.RED, 2, 9));
        pieces.append (new XiangqiPiece (XiangqiPieceType.ELEPHANT, XiangqiColor.RED, 6, 9));
        // 马
        pieces.append (new XiangqiPiece (XiangqiPieceType.HORSE, XiangqiColor.RED, 1, 9));
        pieces.append (new XiangqiPiece (XiangqiPieceType.HORSE, XiangqiColor.RED, 7, 9));
        // 车
        pieces.append (new XiangqiPiece (XiangqiPieceType.CHARIOT, XiangqiColor.RED, 0, 9));
        pieces.append (new XiangqiPiece (XiangqiPieceType.CHARIOT, XiangqiColor.RED, 8, 9));
        // 炮
        pieces.append (new XiangqiPiece (XiangqiPieceType.CANNON, XiangqiColor.RED, 1, 7));
        pieces.append (new XiangqiPiece (XiangqiPieceType.CANNON, XiangqiColor.RED, 7, 7));
        // 兵
        pieces.append (new XiangqiPiece (XiangqiPieceType.SOLDIER, XiangqiColor.RED, 0, 6));
        pieces.append (new XiangqiPiece (XiangqiPieceType.SOLDIER, XiangqiColor.RED, 2, 6));
        pieces.append (new XiangqiPiece (XiangqiPieceType.SOLDIER, XiangqiColor.RED, 4, 6));
        pieces.append (new XiangqiPiece (XiangqiPieceType.SOLDIER, XiangqiColor.RED, 6, 6));
        pieces.append (new XiangqiPiece (XiangqiPieceType.SOLDIER, XiangqiColor.RED, 8, 6));
        
        // 黑方（上方）棋子
        // 将
        pieces.append (new XiangqiPiece (XiangqiPieceType.GENERAL, XiangqiColor.BLACK, 4, 0));
        // 士
        pieces.append (new XiangqiPiece (XiangqiPieceType.ADVISOR, XiangqiColor.BLACK, 3, 0));
        pieces.append (new XiangqiPiece (XiangqiPieceType.ADVISOR, XiangqiColor.BLACK, 5, 0));
        // 象
        pieces.append (new XiangqiPiece (XiangqiPieceType.ELEPHANT, XiangqiColor.BLACK, 2, 0));
        pieces.append (new XiangqiPiece (XiangqiPieceType.ELEPHANT, XiangqiColor.BLACK, 6, 0));
        // 马
        pieces.append (new XiangqiPiece (XiangqiPieceType.HORSE, XiangqiColor.BLACK, 1, 0));
        pieces.append (new XiangqiPiece (XiangqiPieceType.HORSE, XiangqiColor.BLACK, 7, 0));
        // 车
        pieces.append (new XiangqiPiece (XiangqiPieceType.CHARIOT, XiangqiColor.BLACK, 0, 0));
        pieces.append (new XiangqiPiece (XiangqiPieceType.CHARIOT, XiangqiColor.BLACK, 8, 0));
        // 炮
        pieces.append (new XiangqiPiece (XiangqiPieceType.CANNON, XiangqiColor.BLACK, 1, 2));
        pieces.append (new XiangqiPiece (XiangqiPieceType.CANNON, XiangqiColor.BLACK, 7, 2));
        // 卒
        pieces.append (new XiangqiPiece (XiangqiPieceType.SOLDIER, XiangqiColor.BLACK, 0, 3));
        pieces.append (new XiangqiPiece (XiangqiPieceType.SOLDIER, XiangqiColor.BLACK, 2, 3));
        pieces.append (new XiangqiPiece (XiangqiPieceType.SOLDIER, XiangqiColor.BLACK, 4, 3));
        pieces.append (new XiangqiPiece (XiangqiPieceType.SOLDIER, XiangqiColor.BLACK, 6, 3));
        pieces.append (new XiangqiPiece (XiangqiPieceType.SOLDIER, XiangqiColor.BLACK, 8, 3));
    }
    
    // 获取指定位置的棋子
    public XiangqiPiece? get_piece_at (int file, int rank) {
        foreach (var piece in pieces) {
            if (!piece.captured && piece.file == file && piece.rank == rank) {
                return piece;
            }
        }
        return null;
    }
    
    // 切换当前玩家
    public void switch_player () {
        current_player = (current_player == XiangqiColor.RED) ? XiangqiColor.BLACK : XiangqiColor.RED;
    }
}