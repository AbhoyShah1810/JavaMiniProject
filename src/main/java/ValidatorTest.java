import com.logiclab.game.GameValidator;

public class ValidatorTest {
    public static void main(String[] args) {
        String layout = "0,0,START; 1,1,LAVA; 2,2,LAVA; 3,3,LAVA; 4,4,LAVA; 5,5,FLAG";
        String code = "moveRight(5);moveDown(5);";
        int gridSize = 6;

        System.out.println("Testing Level 6...");
        boolean result = GameValidator.validate(layout, gridSize, code);
        System.out.println("Result: " + result);

        if (!result) {
            System.out.println("Validation FAILED.");
        } else {
            System.out.println("Validation PASSED.");
        }
    }
}
