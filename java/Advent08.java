
import java.io.IOException;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Advent08 {

    final String dirs_;
    final Map<String,Pair> map_;
    final Map<String,Offset[]> zoffMap_;
    final long ndir_;

    Advent08( String dirs, Map<String,Pair> map ) {
        dirs_ = dirs;
        map_ = map;
        ndir_ = dirs.length();
        zoffMap_ = new HashMap<String,Offset[]>();
        for ( String loc : map.keySet() ) {
            zoffMap_.put( loc, new Offset[ (int) ndir_ ] );
        }
    }

    long calc08b() {
        String[] locs = map_.keySet().stream().toArray( n -> new String[ n ] );
        String[] starts = Arrays.stream( locs )
                                .filter( l -> l.endsWith( "A" ) )
                                .toArray( n -> new String[ n ] );

        int nstart = starts.length;
        Offset[] offs = new Offset[ nstart ];
        long[] highs = new long[ nstart ];
        for ( int is = 0; is < nstart; is++ ) {
            offs[ is ] = new Offset( starts[ is ], 0 );
        }
        while ( true ) {
            for ( int is = 0; is < nstart; is++ ) {
                Offset off = offs[ is ];
                String loc = off.destLoc_;
                while ( highs[is] == 0 ||
                        highs[is] < Arrays.stream( highs ).max().getAsLong() ) {
                    int ipos =
                        (int) ((highs[is] + (long)offs[is].nstep_) % ndir_);
                    offs[ is ] = getNextZ( offs[ is ].destLoc_, ipos );
                    highs[ is ] += offs[ is ].nstep_;
                }
                int ndistinct = (int) Arrays.stream(highs).distinct().count();
                if ( ndistinct == 1 ) {
                    return highs[0];
                }
            }
        }
        // The answer is 14_265_111_103_729.  It took 18 minutes.
    }

    Offset getNextZ( String loc, int ipos ) {
        Offset[] array = zoffMap_.get( loc );
        if ( array[ ipos ] == null ) {
            array[ ipos ] = calcNextZ( loc, ipos );
        }
        return array[ ipos ];
    }

    Offset calcNextZ( String loc, int ipos ) {
        for ( long i = 0; true; i++ ) {
            Pair pair = map_.get( loc );
            int jpos = (ipos + (int) i) % (int) ndir_;
            boolean isLeft = dirs_.charAt( jpos ) == 'L';
            boolean isRight = dirs_.charAt( jpos ) == 'R';
            if ( ! ( isRight || isLeft ) ) {
                throw new Error();
            }
            loc = isLeft ? pair.left_ : pair.right_;
            if ( loc.endsWith( "Z" ) ) {
                return new Offset( loc, i + 1 );
            }
        }
    }

    public static void main( String[] args ) throws IOException {
        String[] lines =
            new BufferedReader( new InputStreamReader( System.in ) )
           .lines()
           .toArray( n -> new String[ n ] );

        String dirs = lines[ 0 ];
        Map<String,Pair> map = new HashMap<>();
        Pattern pat =
            Pattern
           .compile( "([A-Z1-9]{3}) = [(]([A-Z1-9]{3}), ([A-Z1-9]{3})[)]" );
        for ( int i = 2; i < lines.length; i++ ) {
            Matcher matcher = pat.matcher( lines[ i ] );
            if ( matcher.matches() ) {
                map.put( matcher.group( 1 ),
                         new Pair( matcher.group( 2 ), matcher.group( 3 ) ) );
            }
        }
        Advent08 a = new Advent08( dirs, map );
        System.out.println( a.calc08b() );
    }

    static class Pair {
        final String left_;
        final String right_;
        Pair( String left, String right ) {
            left_ = left;
            right_ = right;
        }
    }

    static class Offset {
        final String destLoc_;
        final long nstep_;
        Offset( String destLoc, long nstep ) {
            destLoc_ = destLoc;
            nstep_ = nstep;
        }
    }

}
