/* xiangqi-piece.vala
 *
 * 中国象棋棋子类定义
 */

public enum XiangqiPieceType {
    GENERAL,    // 将/帅
    ADVISOR,    // 士/仕
    ELEPHANT,   // 象/相
    HORSE,      // 马
    CHARIOT,    // 车
    CANNON,     // 炮
    SOLDIER     // 兵/卒
}

public enum XiangqiColor {
    RED,
    BLACK
}

public class XiangqiPiece : Object {
    public XiangqiPieceType piece_type { get; private set; }
    public XiangqiColor color { get; private set; }
    public int file { get; set; }  // 列（0-8）
    public int rank { get; set; }  // 行（0-9）
    public bool captured { get; set; default = false; }

    public XiangqiPiece (XiangqiPieceType piece_type, XiangqiColor color, int file, int rank) {
        this.piece_type = piece_type;
        this.color = color;
        this.file = file;
        this.rank = rank;
    }

    public string get_name () {
        string color_prefix = (color == XiangqiColor.RED) ? "红" : "黑";
        
        switch (piece_type) {
            case XiangqiPieceType.GENERAL:
                return color_prefix + ((color == XiangqiColor.RED) ? "帅" : "将");
            case XiangqiPieceType.ADVISOR:
                return color_prefix + ((color == XiangqiColor.RED) ? "仕" : "士");
            case XiangqiPieceType.ELEPHANT:
                return color_prefix + ((color == XiangqiColor.RED) ? "相" : "象");
            case XiangqiPieceType.HORSE:
                return color_prefix + "马";
            case XiangqiPieceType.CHARIOT:
                return color_prefix + "车";
            case XiangqiPieceType.CANNON:
                return color_prefix + "炮";
            case XiangqiPieceType.SOLDIER:
                return color_prefix + ((color == XiangqiColor.RED) ? "兵" : "卒");
            default:
                return "未知棋子";
        }
    }

    public string get_resource_name () {
        string color_name = (color == XiangqiColor.RED) ? "red" : "black";
        string type_name = "";
        
        switch (piece_type) {
            case XiangqiPieceType.GENERAL:
                type_name = "general";
                break;
            case XiangqiPieceType.ADVISOR:
                type_name = "advisor";
                break;
            case XiangqiPieceType.ELEPHANT:
                type_name = "elephant";
                break;
            case XiangqiPieceType.HORSE:
                type_name = "horse";
                break;
            case XiangqiPieceType.CHARIOT:
                type_name = "chariot";
                break;
            case XiangqiPieceType.CANNON:
                type_name = "cannon";
                break;
            case XiangqiPieceType.SOLDIER:
                type_name = "soldier";
                break;
        }
        
        return @"pieces/$(color_name)_$(type_name).svg";
    }
}