
import java.io.InputStreamReader;
import java.io.BufferedReader;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Stream;

public class Advent {

    private static Map<String,StreamCondenser> SOLUTION_MAP =
        createSolutionMap();

    public static void main( String[] args ) throws IOException {
        String usage = "\n   "
                     + "Usage: "
                     + Advent.class.getName()
                     + " <id>"
                     + " [<input-file>]"
                     + "\n";
        if ( args.length < 1 ) {
            System.err.println( usage );
            System.exit( 1 );
        }
        String id = args[ 0 ];
        final Stream<String> lines;
        if ( args.length > 1 ) {
            Path path = Paths.get( args[ 1 ] );
            lines = Files.lines( path );
        }
        else {
            lines = new BufferedReader( new InputStreamReader( System.in ) )
                   .lines();
        }
        StreamCondenser condenser = SOLUTION_MAP.get( id );
        String answer = condenser.condense( lines );
        System.out.println( id + " -> " + answer );
    }

    public static String advent01a( Stream<String> stream ) {
        return Integer.toString(
            stream
           .map( t -> t.chars()
                       .filter( Character::isDigit )
                       .collect( () -> new int[ 2 ],
                                 (p, c) -> {
                                      p[ 0 ] = p[ 0 ] == 0 ? c : p[ 0 ];
                                      p[ 1 ] = c;
                                  },
                                  (c1, c2) -> {
                                      c1[ 0 ] = c2[ 0 ];
                                      c1[ 1 ] = c2[ 1 ];
                                  } ) )
           .map( p -> new String( p, 0, 2 ) )
           .mapToInt( Integer::parseInt )
           .sum()
        );
    }

    public static String advent01b( Stream<String> stream ) {
        return advent01a(
            stream
           .map( t -> t.replaceAll( "one", "one1one" )
                       .replaceAll( "two", "two2two" )
                       .replaceAll( "three", "three3three" )
                       .replaceAll( "four", "four4four" )
                       .replaceAll( "five", "five5five" )
                       .replaceAll( "six", "six6six" )
                       .replaceAll( "seven", "seven7seven" )
                       .replaceAll( "eight", "eight8eight" )
                       .replaceAll( "nine", "nine9nine" ) )
        );
    }

    private static Map<String,StreamCondenser> createSolutionMap() {
        Map<String,StreamCondenser> map = new HashMap<>();
        map.put( "01a", Advent::advent01a );
        map.put( "01b", Advent::advent01b );
        return map;
    }

    @FunctionalInterface
    public interface StreamCondenser {
        String condense( Stream<String> stream );
    }
}
