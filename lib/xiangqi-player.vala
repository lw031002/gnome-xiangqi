/* xiangqi-player.vala
 *
 * 中国象棋玩家类
 */

public enum XiangqiPlayerType {
    HUMAN,
    COMPUTER
}

public class XiangqiPlayer : Object {
    public string name { get; set; }
    public XiangqiColor color { get; private set; }
    public XiangqiPlayerType player_type { get; private set; }
    
    public XiangqiPlayer (string name, XiangqiColor color, XiangqiPlayerType player_type) {
        this.name = name;
        this.color = color;
        this.player_type = player_type;
    }
}