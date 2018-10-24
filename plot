#!/bin/bash
strpush(){
    # add a string into the specified stack
	local FLAG=0
	local FS=';'
        local PATHVARIABLE
	if [ -z $2 ] ; then
	   return
        else
            local PATHVARIABLE=${2}
        fi
	if [ ! -z $3 ] ; then FS=$3;fi
        if [  "${1}" ] ; then
           export $PATHVARIABLE="${!PATHVARIABLE:+${!PATHVARIABLE}${FS}}$1"
        fi
}
strpushv(){
    local STRVAR=$1
    local FS=$2
    local i
    shift 2
    while [[ $# -gt 0 ]]; do
        # modified on 20171219, when number of parameter >10
        # for loop failed if no "shift" is used.
        # 20171223, this is due to ${10} ‡ $10 
        #for((i=1;i<= $#;++i)) do 
        # debug
        #echo strpush "\"$(echo "\$$i")\"" ${STRVAR} $FS;
        #echo -n "\$"
        #eval echo $i="\$$i"
        #eval strpush "\"$(echo "\$$i")\"" ${STRVAR} $FS; 
        #echo strpush "$1" ${STRVAR} $FS
        strpush "$1" ${STRVAR} $FS; shift;
    done
}
strsplit(){
    local arr="${3}"
    local sp="${2}"
    local remainder="${1}"
    local i
    local part
    i=0;
    while :
    do
        part="${remainder%%;*}"
        #echo "${part}"
        #simulate return array of values
        eval "${arr}[$i]=\${part}"
        if [ "${part}" == "${remainder}" ]; then break; fi
        remainder="${remainder#*;}"
        i=$(($i+1))
    done
}
gnupara(){
    local input="${1}"
    local output=
    local i
    local buf
    local pre="${2}"

    shift
    strsplit "${input}" ";" buf
    for ((i=0;i<${#buf[@]};++i)) do
        if [ "${buf[$i]}x" == "0x" ]; then 
            output="${output:+${output};}unset ${pre}"
        elif [[ "${buf[$i]}" =~ "for" ]]; then
            output="${output:+${output};}set ${buf[$i]}"
        else
            output="${output:+${output};}set ${pre} ${buf[$i]}"
        fi
    done
    echo "${output[@]}"
}
gnupara1(){
    local input="${1}"
    local output=
    local i
    local buf
    local pre="${2}"

    shift
    strsplit "${input}" ";" buf
    for ((i=0;i<${#buf[@]};++i)) do
        if [ "${buf[$i]}x" == "1x" ]; then 
            output="${output:+${output};}set ${pre}"
        #elif [[ "${buf[$i]}" =~ "for" ]]; then
            #output="${output:+${output};}set ${buf[$i]}"
        else
            output="${output:+${output};}set ${pre} ${buf[$i]}"
        fi
    done
    echo "${output[@]}"
}
gnupara01(){
    local input="${1}"
    local output=
    local i
    local buf
    local pre="${2}"

    shift
    strsplit "${input}" ";" buf
    for ((i=0;i<${#buf[@]};++i)) do
        if [ "${buf[$i]}x" == "0x" ]; then 
            output="${output:+${output};}unset ${pre}"
        elif [ "${buf[$i]}x" == "1x" ]; then 
            output="${output:+${output};}set ${pre}"
        elif [[ "${buf[$i]}" =~ "for" ]]; then
           output="${output:+${output};}set ${buf[$i]}"
        else
            output="${output:+${output};}set ${pre} ${buf[$i]}"
        fi
    done
    echo "${output[@]}"
}
plot(){
local __HELP__
read -d '' _HELP_ <<"__PLOTHELP__"
Syntax:
    plot [-h|--help]
    plot -c "plot 'data.dat' u 1:2 i 0 w lp"
    plot -c "plot sin(x)"
    plot [-D] "data.dat" [-i 0] [-f 1] [-sc 2] [--row ::1::10 ]
    plot [-D] "data.dat" --gn 2  -i 0 0 -f 1 1 -s 2 3 [--row ::1::10]
    plot -e "sin(x)"
    plot -e '"+" u 1:(sin($1))' --xlim [-pi:pi]
    plot -e '"data.at" u 1:2'
    plot -F "g(x)=exp(-x**2/2)" -e "sin(x)"
    plot -S "script1.dem" ["script2.dem"] [...]
    plot --test 
    plot --test ["term"]|["palette"]|["arrow|as|arrowstyle"]["enhanced|enhace"] 
    plot --show "colors"
    plot -H|--HELP xtics

Introduction:
      This "plot" function invoking gnuplot to plot under bash (CLI interface). It also has another alias splot 
    plot 3d images, just add "alias splot='plot --splot'" in your bash starup file (such as .bash_alias). It 
    classfied data into several modes, then pares parameters into gnuplot. 
     
      Data mode:
           
           'data','datahist',...(default):
      Simulate gnuplot plots data file by gives number of lines (default 1), index,columns,data block
      Syntax: 
                   plot [-D] "data.dat" [-i 0] [-f 1] [-sc 2] [--row ::1::10 ]
                   plot [-D] "data.dat" --gn 2  -i 0 0 -f 1 1 -s 2 3 [--row ::1::10]

           'expression': 
      Simulate gnuplot "plot sin(x)" function-like plot, also support user-defined function, and virtual or real file.
      Syntax: 
                   plot -e "sin(x)"
                   plot -F "g(x)=exp(-x**2/2)" -e "sin(x)"
                   plot -e '"+" u 1:sin($1)' --xlim [-pi:pi]
                   plot -e '"data.at" u 1:2'
         
           'command':                           
      Accepting gnuplot commands directly, but maybe only main plot command is given, general setting is provided
    by this "plot" function.
      Syntax:
                   plot -c "plot 'data.dat' u 1:2 i 0 w lp"
                   plot -c "plot sin(x)"
          
            'script':
      Simulate gnuplot load/call script "gnuplot < script.gp", supporting multiple scripts, this "plot" function
    did nonthing more than redirection of "gnuplot < script".
      Syntax:
                   plot -S "script1.dem" ["script2.dem"] [...]
    
            'test':
      Simulate gnuplot test command, just like run "test" in gnuplot to get line style and other information.
    Several tests are supported, like gnuplot orginal "test" for "png/eps/pdf[cairo]" terminal, "palette" test, 
    "arrow" test, "enhanced" test.
      Syntax: 
                   plot --test 
                   plot --test "term"|"palette"|"arrow|as|arrowstyle"|"dash"
    
            'show':
      Simulate gnuplot show command, accept same input from gnuplot, output is STDOUT, but cannot purse subtopic in 
    gnuplot because it do not accept input friendly, so sometimes you should press "Enter" several times just like 
    in gnuplot, do not worried that this "plot" is stucked. Just move on by pressing "Enter". Gnuplot is friendly 
    under even in CLI interface for help, so you just can type: gnuplot (run "gnuplot")->show colors.
     Synatx:
                   plot --show "colors"
     
            'help':
      Simulate gnulot help command, print output into STDOUT, like 'show' not very friendly, just use: 
    gnuplot(run "gnuplot")-> help plot (anything about gnulot)
      Syntax:
                   plot -H|--HELP xtics

            'thishelp':
      Print help for this "plot" .   
      Syntax:
                   plot [-h|--help]

   For only watch the parsed command will be called by "gnuplot", for check error, and create script which can
be called by "gnuplot".
      Syntax:
                   plot [...] -d
                   plot [...] -d > save.dem 
   where [...] means option-paramter pairs given by any mode.

options:
            -a|--arrow "1 from 2.4,0.45 to 2.98,0.85 lt -1 lw 2 size .3,15"
                set arrow <tag> {nohead | head | backhead | heads}
                                {size <headlength>,<headangle>{,<backangle>}}
                                {filled | empty | nofilled | noborder}"
            --ang|--angles|--angle "degrees|radians"
            --border [0] [8;lt 4]
            --bw|boxwidth "0.5 relative"|"2 absolute" {influnce histrogram, boxes,...}
            -c|--command 'command1;command2;[...]'
            --cblim [0:250]
            --cntrlabel "onecolor"|"start 5 interval 20"|"format <fmt> font <font>"
            --clrbx [0|1|]
            --cntr [base|surface|both]
            --cntrparam "levels 10"  levels discrete <z1,z2,...>
                        "for [n=1:4] cntrparam levels discrete n**2"
            --crop "crop"|"nocrop"
            -d|--debug
            -D|--datafile|--infile
            --data {similar with -e}
            --dt|--dashtype 1 2 3 "(2,4,4,7)" ".. " "(2,5,2,15)"
            --dummy "u,v"
            -e|--expression|--expressionession|--expressionesions {for expressionession} 
               { '+' u 1:(sum100(x)):(square(x)) '+' used for virtual data file;}
            --enhan
            -F|--function|--functions [function definitiions]
                "fourier(k,x)=4./pi/(2*k-1)*sin((2*k-1)*x)" "sum100(x)=sum [k=1:5] fourier(k,x)" 
            -f|--first
            --fill "empty|pattern [n]|solid [1.0] [border lt -1|noborder]"
            --fillsteps|--fillstep
            --font 'Times,15'|',15'|'Arial,12'|"Helvetica,14"|"Courier,12"
            --fp|--fill-pattern 5
            --fsteps|--fstep
            --fx|--formatx "%D %E" (for geographic)
            --fy|--formaty
            -g|--grid "[xtics] [ytics] [lw 2][1|0]"
            --gn|--graph-number
            -H|--HELP {invoking gnuplot help ... }
            -h|--help
            --hidd|--hidden3d [0|1|] [back|front] [offset 0] [trianglepattern 3] [undfined 1] [altdiagonal bentover]
            --hist "rowstacked"|"columnstacked"
            --histeps|--hsteps|--histep|--hstep
            -i|--index
            --is|iso|--isosamples 50
            -k|--key "bottom right"|"outside top center"|"left bottom Left box font 'Times,15'"
                     "at graph .9,.9 spacing 2 font 'Helvetica,14'"
                     "right center samplen 0.8"
            -l|--legend [legent list]
            --label "'Approximation error' right at 2.4,0.45 offset -.5,0 font 'Helvetica,20'"
            --lc|--line-color 'rgb "#FF0000"'
                              'rgb "black|red|green|blue|yellow|cyan|orange|bisque"'
                              'rgb "dark-violet|dark-orange|dark-red|sea-blue"'
                              'rgb "steelblue|seagreen|goldenrod"'
            --log|--logscale  "xy" or "x" or "y" or "xy" "y" or "cb"
            --lm|--linemode  [lines|points|linepoints|impulses|dots|errorbars|steps|boxes|boxerrorbars]
                              ["filledcurves above y1=0.07"]
                              ["candlesticks lt -1 lw 2 whiskerbars"]
                              ["vec size 0.06,15 filled"]
                              ["pm3d at b"]
                              ["rgbimage"]
            --ls|--linestyle
            --lsi|--linestyleindex [1,2,...]
            --lti|--linetypeindex [1, 2, ..., refer plot --test]
            --lw|--line-width
            -m|--multiplot "layout 2,2 [title 'Derivatives of Sin(x)' font 'Times,22']" 
            --map [cartesian|spherical|cylindrical]
            --marg|--margin|--margins "0.2,0.8,0.2,0.8"
            -O|--OUT|--out-file
            -o|--origin "0,.5" [""]
            --open "fbi|fbgs -r 600|display"
            -p|--para|--parametric "sin(7*t),cos(11*t)"
            --pal|--palette [defined (0 'black',1 'gold|aquamarine',[1 'red'],2 'gold')]
                            [gray positive]
            --pm3d [at b|s]
            --polaron [1,1,...]
            --print
            --ps|--pointsize
            --pt|--pointtype 7
            -q|--quiet {do not open figure after it is plotted}
            --row  ::20::80
            -s|--second
            --sam|samp|--sample|--samples 200
            --show "colors"|"datafile binary filetypes"
            --size "[[no]squre|ratio <1>|noratio] 0.5,0.5" 
            --splot {add 'alias splot="plot --splot"' in .bash_alias file}
            --steps|--step
            --surf [implicit|explicit|0]
            -T "png font 'Times,15' size 1080,720 linewidth 2"
            -t|--term|--terminal
            --test [palette]
            --tic 
            --title "\\"Gibbs'phenomenon\\" tc rgb 'black' offset -3,0 font 'Times,30'"
                    "\"sin\'\'(x)=cos(x)\""  
            --tlim [0:-2]
            --tranoff
            --tranon
            --tsize 1080,720
            -X  {flush the buffer}
            --xlabel "'Time (s)' [font 'Times,l8']"
            --xlim [-10:10]
            --x2lim [-10:10]
            --xmtic  2
            --x2mtic 2
            --xtic [axis|border] [[no]mirror] [in|out] [scale [default|1[,1]]] [numeric|timedate|geographic]
                   ["\\-20 2"|"\\-1,0.1,0"] 
                   "('{/Symbol p}' pi,'{/Symbol p}/2' pi/2,'-{/Symbol p}/2' -pi/2, '-{/Symbol p}' -pi, '0' 0)"
                   "0,0.12*pi,2*pi [format '%.10f'] [rotate by -45]"
            --x2tic 
            --xycol [0]|['0:(sqrt(\\\$1*\\\$1+\\\$2*\\\$2))' or "1:2"]
            --xyp|--xyplane "at -1"|"relative 0"
            --ylabel "'Amplitude (V)' [font 'sans,18']"
            --ylim
            --y2lim 
            --ymtic 
            --y2mtic
            --ytic [[axis] nomirror]
            --y2tic "\\-100 10" {if has y2tic, ytic should set "nomirror"}
            --view "29,53"|map
            --viewxyz "[no]equal [xy|xyz]"
            -u|--uft8
            --za|--zeroaxis [zeroaxis|yzeroaxis]
            --zlim
            --ztic
examples:
    plot HYP_50M_SR_350px2.txt --lm rgbimage --xycol 0 --lsi 0  --tsize 175,350
    plot world.dat --xlim [-180:180] --ylim [-90:90] --xtic "\-180,30,180 geographic" 
         --ytic "\-90,30,90 geographic" --lm l --za "yzeroaxis" --fx '"%D %E"' --fy '"%D %N"' 
         --title "'The earth' offset -3,0 font 'Times,25'"
    plot --gn 2 -D "world.dat" "world.cor" -f 1 1 -s 2 2 --xlim [-180:180] --ylim [-90:90] 
         --xtic "\-180,45,180 geographic" --ytic "\-90,30,90 geographic" 
         --ls "w l lc rgb 'blue'" "w p lt 1 pt 1" --za "yzeroaxis" --fx '"%D %E"' 
         --fy '"%D %N"' --title "'The earth' offset -3,0 font 'Times,25'" 
    plot -e "[0:2*pi] exp(x)*sin(1/x)" "[0:0.2] exp(x)*sin(1/x)" -m --sample 1000 
         --origin "" "0.2,0.4" --size "" "0.25,0.25" --xtic "0.4" "0.1" --grid 1 -l "exp(x)*sin(1/x)" 
         --arrow "from .1,2.1 to screen 0.25,.45 front lt -1" 0 --object "ellipse center 0.13, 0 size .4,4" 
    plot -e '"++" u 1:2:(-0.2*sin($1)*cos($2)):(0.2*cos($1)*sin($2))' --lm "vec size 0.06,15 filled" 
         --xlim [0:pi] --ylim [0:pi] --iso 20 --sam 20 --tsize "800,800" 
    plot -e "sin(x)/x" --lc "rgb 'red'" --lw 2 -l "sin(x)/x" --border 0 --xlim [-10:10] --ylim [-0.4:1] 
         --arrow "from -10,-0.4 to 12,-0.4 fill;from -10,-0.4 to -10,1.1 fill" --tic "nomirror" 
         --sam 200  --size "square 0.8,0.8" -g 1 
    plot -e "4/pi*sin(x)" "4/pi*(sin(x)+sin(3*x)/3)" "4/pi*(sin(x)+sin(3*x)/3+sin(5*x)/5)" --xlim [-pi:pi]
    plot -e "4/pi*sin(x)" "4/pi*(sin(x)+sin(3*x)/3)" "4/pi*(sin(x)+sin(3*x)/3+sin(5*x)/5)" \\
         "sgn(sin(x))" --xlim [-pi:pi] --legend "S1" "S3" "S5" "Soo"
    plot -e "sin(1/x) axis x1y1" "100*cos(x) axis x1y2"  -l "sin(1/x)" "100*cos(x)" --ytic "nomirror" \\
         --y2tic "\\-100, 10"   --dt 1 2 --lc "rgb 'black'" "rgb 'black'"
    plot -e "besj0(x)" "sin(x)" --lm "boxes" "boxes" --xlim [-6:6] --lc "rgb 'red'" "rgb 'green'" \\
         --fp --lw 0.5
    plot -e "besy0(x)" "besy0(x)" --lm "filledcurves above y1=0.07" --xlim [0:50] -l "besy0(x)"  \\
         --lc "rgb 'red'" "rgb 'red'" --ylim [-0.5:0.6] --sample 400
    plot -e "'+' u 1:(-\\\$1):(-\\\$1**2)" "\\-x" "\\-x**2" --lw 1 3 3 --lm filledcurves --fp 5
    plot -p "sin(7*t),cos(11*t)" --sample 1000 --tlim [0:2]
    plot -e "t" --tlim [0:12*pi] --sample 500 --xtic "axis nomirror 15,2,30" --ytic "axis nomirror 10,2,20"
       --polaron 1 --za zeroaxis -g  --border 0 --tsize 1000,1000 --rtic 0 
    plot -F "fourier(k,x)=4./pi/(2*k-1)*sin((2*k-1)*x)" "sum100(x)=sum [k=1:5] fourier(k,x)" \\
         -e "\\-sum100(x)" "sgn(x-pi)" --xlim [0:2*pi] --sample 1000
    plot -e "besj0(x)" "besj1(x)" "besy0(x)" "besy1(x)" -m "layout 2,2" \\
         -l "besj0(x)" "besj1(x)" "besy0(x)" "besy1(x)"
    plot -e "sin(x)" "cos(x)" "\-cos(x)" "\-sin(x)" -k "outside top center" 
         -m "layout 2,2 title 'Derivatives of Sin(x)' font 'Times,22'" --xlim [-pi:pi] --lc "rgb 'red'" 
         --title '"sin(x)"' "\"sin\'(x)=cos(x)\"" "\"sin\'\'\'(x)=-cos(x)\"" "\"sin\'\'(x)=cos(x)\""  
         --arrow "1 from screen 0.45,0.8 to screen 0.65,0.8" "2 from screen 0.85,0.7 to screen 0.85,0.3" 
                 "3 from screen 0.7,0.15 to screen 0.4,0.15" "4 from screen 0.35,0.3 to screen 0.35,0.7"
    splot -e "for [n=0:3] 'rocket.jpg' binary filetype=auto center=(60+130*n,210*0.1*(1+n),0) dy=0.2*(1+n)" 
          --lsi 0 --lm image --view map  --clrbx 0  --pal "gray positive" --xlabel "'Year'" 
          --ylabel "'Number of Oprational Warheads' offset -2" --cblim [0:250]
          --xtic "scale 0;for [n=0:3] xtics (sprintf('%d',1990+10*n) 60+130*n)" 
          --ytic "for [n=0:3] ytics (sprintf('%d',n*10) 55*n)" 
          --title "'Elbonian Warhead Inventory' font 'Times,25'" 
    splot -e "x*y" --cntr base --view map --cntrparam "for [n=1:4] cntrparam levels discrete n**2" 
          --lsi 0  --xlim [0:5] --ylim [0:5] --cntrlabel "onecolor" 
          --object "for [n=1:4] object n circle at n,n size 0.2 front fillcolor rgb '#ffffff' lw 0" 
          --fill "solid" --label "for [n=1:4] label n sprintf('%d',n**2) at n,n center front" 
    splot -e "besj0(x**2+y**2)" --is 40 --view "29,53" --xlim [-4:4] --ylim [-4:4] --ztic 1 
          --title "'J_0(r^2)'" --hidd 1 --lc "rgb 'black'"
    splot -e "besj0(x**2+y**2)" --is 40 --view "29,53" --xlim [-4:4] --ylim [-4:4] --ztic 1 
          --title "'J_0(r^2)'" --pm3d "at s hidden3d 1" --surf 0 --sample 30 --is 30 --lc "rgb 'orange'"
    splot -e "'++' u 1:2:(sin(\\\$2))" --lm l --xlim [-pi:pi] --ylim [-pi:pi] --map cylindrical
          --zlim [0:pi] --is 60 --view "90,0" --tic 0 --border 0
    splot -e "sin(x)+cos(2*y)" --is 100 --xlim [-4:4] --sample 100 --surf 0 --cntr base 
          --cntrparam "levels 10" --view "map"   --ylim [-4:4]
    splot -e "sin(x)+cos(2*y)" --lm l --cntr both --iso 50 --sam 50 --cntrparam "levels 10" 
          --hidd 1 --xlim [-4:4] --ylim [-4:4] --ztic 1 --lc "rgb '#cccccc'"
    splot -e '"++" u 1:2:(0.4*cos($2)*sin($1)):(-0.2*sin($1)*cos($2)):(0.2*cos($1)*sin($2)):(0.2*cos($1))'
          --lm "vec size 0.06,15 filled" --xlim [-pi:pi] --ylim [-pi:pi] --zlim [-pi:pi] --iso 20 
          --sam 20 --tsize "800,800" --ztic "1.5" --view "37,300" 
    splot -F "f(x,y)=sin(x)*cos(y)" -e "f(x,y);f(x,y)" --lm "pm3d at b" l  --xlim [-pi:pi] --ylim [-pi:pi]
          --iso 40 --sam 40 --hidd front --xyp "at -1"
__PLOTHELP__
    #                  0        1       2           3         4       5       6        7
    #local datamodes=('command' 'data' 'expression' 'flush' 'help' 'script' 'show' 'thishelp' )
    local datamode='data' #default mode
    #------------------------------- local variables ----------------------------
    #== specify buffuer for command stack
    local buf=GNUPLOT_PLOTBUF            # call by gnuplot, "gnuplot -e '${!buf}'"
    local cmdbuf=GNUPLOT_CMDBUF          # for main plot command directly from user
    local databuf=GNUPLOT_DATABUF        # for both data or expressioness
    local funcbuf=GNUPLOT_FUNCBUF        # for user-defined functions,which can by used in expression mode
    local graphbuf=GNUPLOT_GRAPHBUF      # for set graph 
    local prebuf=GNUPLOT_PREBUF          # for preconfiguration for gnuplot, used in  "data" "expression" "command"
    local postbuf=GNUPLOT_POSTBUF        # for postconfiguration for gnuplot
    local script=                        # for containing file names of gnuplot scripts
    local showhelp=                      # for gnuplot show and help parameter
    local testbuf=GNUPLOT_TESTBUF        # for test code,   simulate "test" in gnuplot

    #tools
    local open=     # used to open images
    local plotengine="plot" # gnuplot engine: plot or splot

    #== terminal setting
    local terminal=     #complex terminal
    local crop=
    local enhan=
    local font=
    local fontscale=
    local interlace=
    local mono=
    local term='png'
    local tran=
    local tsize=  #terminal or canvas size
    local utf8=0
    #== output
    local defaultoutfile='gnuplot'
    local outfile=
    local suffix='.png'
    #== graph setting
    local angle=
    local fill=
    local fillpat=
    local fillpaton=0       #use default fill pattern
    local functionstyle=
    local graphnumber=1
    local isosamples=
    local linenum=0         # in some case multiple lines in one graph
    local linestylenum=
    local multiplot=  
    local multiploton=0    # 1 indicate multiple plot on
    local origin=
    local parametric=0
    local polaron=         # 1 indicate polar
    local samples=
    local size=             #
    #== data block, for 'data' data
    local data=
    local datap=        #tempoary variable
    local datablock=   # temporary variable
    local dummy=
    local infile=
    local indexnum=0
    local firstcol=1
    local secondcol=
    local xycol=      # more column, as argument of using
    local row=        # for every
    #== line properties
    local dashtype=    # user_defined type 
    local dashtypeindex=
    local hist=       # for histgrams
    local linestyleindex=
    local linestyle=    # user_defined style, for example for candlesticks
    local linemode=   # used by w
    local linetypeindex=
    local linecolor=
    local linewidth=
    local pointtype=
    local pointsize=
    #legend and labels
    local arrow=
    local border=
    local boxwidth=
    local formatx=
    local formaty=
    local grid=
    local label=
    local legend=
    local legendi="notitle" 
    local key=
    local object=
    local rtic=
    local tic=    
    local title=
    local xlabel=
    local xtic=
    local xmtic=
    local x2label=
    local x2tic=
    local x2mtic=
    local ylabel=
    local ytic=
    local ymtic=
    local y2label=
    local y2tic=
    local y2mtic=
    local zeroaxis= # 1 inciate have zero axis
    # data scale 
    local logscale=
    local tlim=   #for parameter 
    local xlim=
    local ylim=
    local x2lim=
    local y2lim=
    # 3d, contour, heat images
    local cntr=
    local cntrparam=
    local hidd=
    local mapping=
    local margins=
    local pm3d=
    local surf=
    local ulim=
    local view=
    local viewxyz=
    local vlim=
    local xyp=
    local ztic=
    local zlim=
    #colors
    local cblim=
    local cntrlabel=
    local clrbx=
    local palette=
    #test
    local testtype="term" #"palette"|"arrowstyle"
    #temoprory variable
    local i=
    local iline=     # line loop index for one graph
    local isff=0     # check first parameter is input file, supress help output
    local debugon=0  #
    local cmd=       # finally execute commands
    local quiet=0
    local printtofile=0
    
    # parameter parsing
    # check first parameter is a file or not
    if [ $# -eq 0 ] ; then datamode="thishelp";elif [ -f $1 ] ; then infile=$1;shift;isff=1;fi
    while  [ $# -gt 0 ]
    do
        case "$1" in 
            "-a"|"--arrow")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do arrow[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--ang"|"--angles"|"--angle")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do angle[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--border")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do border[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--bw"|"--boxwidth")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do boxwidth[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            # accept gnuplot command directly,so supress automatical data match
            "-c"|"--command")
                datamode="command";graphnumber=0; while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]];
                    do strpush "$2" $cmdbuf;shift; done; shift;;
            "--cblim")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do cblim[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--cntrlabel")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do cntrlabel[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--clrbx")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do clrbx[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--cntr")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do cntr[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--cntrparam")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do cntrparam[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--crop")
                crop="$2";shift 2 ;;
            "-d"|"--debug")
                debugon=1;shift;;
            # input date file
            "-D"|"--datafile"|"--infile")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do infile[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--data")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do data[$i]="$2"; i=$(($i+1));shift; done
                graphnumber=$i;shift;;
            "--dt"|"--dashtype")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do dashtype[$i]="${2#\\}"; i=$(($i+1));shift; done
                shift;;
            "--dummy")
                dummy="$2";shift 2;;
            # expressionession directly
            "-e"|"--expression"|"--expressionession"|"--expressionesions")
                datamode="expression"; i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do data[$i]="${2#\\}"; i=$(($i+1));shift; done
                graphnumber=$i;shift;;
            "--enhan"|"--enhanced")
                enhan="enhanced";shift;;
            "-F"|"--function"|"--functions")
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do strpush "$2" $funcbuf;shift; done; shift;;
            # input file data column
            "-f"|"--first")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do firstcol[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            # fill pattern
            "--fill")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do fill[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--fillsteps"|"--fillstep")
                linemode='fillsteps'; shift ;;
            "--font")
                font="$2";shift 2;;
            "--fp"|"--fill-pattern")
                fillpaton=1; i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do fillpat[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            #fsteps
            "--fsteps"|"--fstep")
                linemode='fsteps'; shift ;;
            "--fs"|"--functionstyle")
                fillpaton=1; i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do functionstyle[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--fx"|"--formatx")
                i=0;
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do formatx[$i]="$2"; i=$(($i+1));shift;done;shift;;
            "--fy"|"--formaty")
                i=0;
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do formaty[$i]="$2"; i=$(($i+1));shift;done;shift;;
            "-g"|"--grid")
                i=0;
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do grid[$i]="$2"; i=$(($i+1));shift;done;shift;;
            "--gn"|"--graph-number")
                graphnumber="$2"; shift 2;;
            # data index
            "-i"|"--index")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do indexnum[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--interlace")
                interlace="$2";shift 2;;
            "--is"|"--iso"|"--isosamples")
                isosamples="$2";shift 2;;
            "-H"|"--HELP")
                datamode="help";showhelp="${2}";shift 2;;
            "-h"|"--help")
                datamode="thishelp";shift;;
            "--hidd"|"--hidden3d")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do hidd[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--hist")
                datamode="datahist"; i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do hist[$i]="$2";col0on[$i]=1; i=$(($i+1));shift; done
                shift;;
            #hteps
            "--histeps"|"--hsteps"|"--histep"|"--hstep")
                linemode='histeps';shift;;
            #complex legends
            "-k"|"--key")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do key[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "-l"|"--legend")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do legend[$i]="${2#\\}"; i=$(($i+1));shift; done
                shift;;
            "--label")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do label[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--lc"|"--line-color")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do linecolor[$i]="$2"; i=$(($i+1));shift; done
                shift;;
                #line-line
            "--ll"|"--lines-lines"|"--line-line"|"--lines-line"|"--line-lines")
                linemode[1]='lines';shift;;
            "--log"|"--logscale")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do logscale[$i]="$2"; i=$(($i+1));shift; done
                shift;;
                #line-point
            "--lp"|"--line-point"|"--line-points"|"--lines-point"|"--lines-points")
                linemode[1]='points';shift;;
            "--lm"|"--linemode")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do linemode[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--ls"|"--linestyle")
                i=0;
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do linestyle[$i]="$2";i=$(($i+1));shift; done
                shift;;
            "--lsi"|"--linestyleindex")
                i=0;
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do linestyleindex[$i]="$2";i=$(($i+1));shift; done
                shift;;
            "--lsn"|"--linestylenum")
                linestylenum="$2";shift 2;;
            "--lti"|"--linetypeindex")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do linetypeindex[$i]="${2#\\}"; i=$(($i+1));shift; done
                shift;;
            "--lw"|"--line-width")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do linewidth[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "-m"|"--multiplot")
                multiploton=1;if [[ ! "$2" =~ ^- ]]; then multiplot="$2";shift;fi;shift;;
            "--map"|"--mapping")
                mapping="$2";shift 2;;
            "--marg"|"--margin"|"--margins")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do margins[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "-O"|"--OUT"|"--out-file")
                outfile="$2";shift 2;;
            "-o"|"--origin")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do origin[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--object")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do object[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--open")
                open="$2";
                shift 2 ;;
            "-p"|"--para"|"--parametric")
                parametric=1; datamode="expression";i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do data[$i]="${2#\\}";parametric[$i]=1; i=$(($i+1));shift; done
                graphnumber=$i;shift;;
            "--pal"|"--palette")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do palette[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--pm3d")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do pm3d[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--polaron")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do polaron[$i]=$2; i=$(($i+1));shift; done
                shift;;
            "--print")
                printtofile="$2";shift 2;;
            "--ps"|"--pointsize")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do pointsize[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--pt"|"--pointtype")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do pointtype[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "-q"|"quiet")
                quiet=1;shift;;
            "--row")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do row[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--rtic")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do rtic[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "-S"|"--script")
                datamode='script'
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do script[$i]="$2"; i=$(($i+1));shift; done
                # obmit remaining arguments
                shift $#;; 
            "-s"|"--second")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do secondcol[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--sam"|"samp"|"--sample"|"--samples")
                samples="$2";shift 2;;
                # gnuplot built-in information
            "--show")
                datamode="show";showhelp="${2}";shift 2;;
            "--size")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do size[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--splot")
                plotengine="splot";shift;;
            "--steps"|"--step")
                linemode="steps";shift ;;
            "--surf")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do surf[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "-T")
                terminal="$2";shift 2;;
            "-t"|"--term"|"--terminal")
                term="$2"; shift 2 ;;
            "--test")
                datamode="test"; graphnumber=0;
                if [ ! -z "$2" ] && [[ ! "$2" =~ ^- ]]; then testtype="$2";shift;fi
                shift ;;
            "--tic")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do tic[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--title")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do title[$i]="${2#\\}"; i=$(($i+1));shift; done
                shift;;
            "--tlim")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do tlim[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--tranoff")
                tran="notransparent";shift;;
            "--tranon")
                tran="transparent";shift;;
            "--tsize")
                tsize="$2";shift 2;;
             "-u"|"--utf8")
                 uft8=1;shift 2;;
             "--ulim")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do ulim[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--view")
                view="$2";shift 2;;
            "--viewxyz")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do viewxyz[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--vlim")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do vlim[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "-X")
                datamode="flush";graphnumber=0;shift;;
            "--xlabel")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do xlabel[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--x2label")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do x2label[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--xlim")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do xlim[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--x2lim")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do x2lim[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--xtic")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do xtic[$i]="${2#\\}"; i=$(($i+1));shift; done
                shift;;
            "--x2tic")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do x2tic[$i]="${2#\\}"; i=$(($i+1));shift; done
                shift;;
            "--xmtic")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do xmtic[$i]="${2#\\}"; i=$(($i+1));shift; done
                shift;;
            "--x2mtic")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do x2mtic[$i]="${2#\\}"; i=$(($i+1));shift; done
                shift;;
                #complex columns
            "--xycol")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do xycol[$i]="$2"; i=$(($i+1));shift; done
                graphnumber=$i;shift;;
            "--xyp"|"--xyplane")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do xyp[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--ylabel")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do ylabel[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--y2label")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do y2label[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--ylim")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do ylim[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--y2lim")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do y2lim[$i]="$2"; i=$(($i+1));shift; done
                shift;;
            "--ytic")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do ytic[$i]="${2#\\}"; i=$(($i+1));shift; done
                shift;;
            "--y2tic")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do y2tic[$i]="${2#\\}"; i=$(($i+1));shift; done
                shift;;
            "--ymtic")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do ymtic[$i]="${2#\\}"; i=$(($i+1));shift; done
                shift;;
            "--y2mtic")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do y2mtic[$i]="${2#\\}"; i=$(($i+1));shift; done
                shift;;
                #zero axis
            "--za"|"--zeroaxis")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do zeroaxis[$i]="${2}"; i=$(($i+1));shift; done
                shift;;
            "--zlim")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do zlim[$i]="${2}"; i=$(($i+1));shift; done
                shift;;
            "--ztic")
                i=0
                while [[ ! "$2" =~ ^- ]] && [[ $# -gt 1 ]]; do ztic[$i]="${2#\\}"; i=$(($i+1));shift; done
                shift;;
            *)
                datamode="thishelp";shift ;;
        esac
    done
    #====== terminal confugration pushed in $prebuf
    case "${term}" in
        "eps"|"epscairo")
            if [ "${term}" == "eps" ]; then term="${term}cairo";fi
            suffix=".${term%cairo}";
            tsize="7cm,7cm" 
            enhan="enhanced"
            fontscale="0.4"
            font="Sans Bold,12"
            tran="transparent"
            [[ ! -z "${legend}" ]] && [[ ! "${key}" =~ "font" ]] && key="font 'Times Bold,16'${key:+;${key}}"
            [[ ! -z "${xlabel}" ]] && [[ ! "${xlabel}" =~ "font" ]] && xlabel="font 'Helvetica Bold,18'${xlabel:+;${xlabel}}"
            [[ ! -z "${ylabel}" ]] && [[ ! "${ylabel}" =~ "font" ]] && ylabel="font 'Helvetica Bold,18'${ylabel:+;${ylabel}}"
            [[ ! -z "${y2label}" ]] && [[ ! "${y2label}" =~ "font" ]] && y2label="font 'Helvetica Bold,18'${y2label:+;${y2label}}"
            [[ ! "${title}" =~ "font" ]] && title="${title:+${title} font 'Symbol Bold,19'}"
            linewidth="${linewidth:-1.5}"
            pointsize="${pointsize:-0.3}"
            if [ -z "${terminal}" ] ; then 
                terminal="${term} ${tran} ${enhan} font '${font}' fontscale ${fontscale} size ${tsize} linewidth 0.5"
            fi 
            ;;
        "pdf"|"pdfcairo")
            if [ "${term}" == "pdf" ]; then term="${term}cairo";fi
            suffix=".${term%cairo}";
            if [ -z "${open}" ]; then
                if [ ${TERM} == "linux" ]; then open="fbgs -r 600"
                else open="evince"; fi
            fi

            tsize="7cm,7cm" 
            enhan="enhanced"
            font="Sans Bold,12"
            fontscale="0.4"
            tran="transparent"
            linewidth="${linewidth:-1.5}"
            pointsize="${pointsize:-0.3}"
            [[ ! -z "${legend}" ]] && [[ ! "${key}" =~ "font" ]] && key="font 'Times Bold,16'${key:+;${key}}"
            [[ ! -z "${xlabel}" ]] && [[ ! "${xlabel}" =~ "font" ]] && xlabel="font 'Helvetica Bold,18'${xlabel:+;${xlabel}}"
            [[ ! -z "${ylabel}" ]] && [[ ! "${ylabel}" =~ "font" ]] && ylabel="font 'Helvetica Bold,18'${ylabel:+;${ylabel}}"
            [[ ! -z "${y2label}" ]] && [[ ! "${y2label}" =~ "font" ]] && y2label="font 'Helvetica Bold,18'${y2label:+;${y2label}}"
            [[ ! "${title}" =~ "font" ]] && title="${title:+${title} font 'Symbol Bold,19'}"
            if [ -z "${terminal}" ] ; then 
                terminal="${term} ${tran} ${enhan} font '${font}' fontscale ${fontscale} size ${tsize} linewidth 0.5"
            fi 
            ;;
        "jpeg"|"jpg"|"png"|"pngcairo")
            if [ "${term}" == "jpeg" ] || [ "${term}" == "jpg" ]; then suffix='.jpg';term="jpeg";fi
            if [ "${term}" == "png" ] ; then term="${term}cairo";fi; suffix=".${term%cairo}"
            if [ "${printtofile}x" == "1x" ]; then 
                tsize="1800,1800" #600dpi,2.4inch(about 6cm),20% crop,however,10cm is every good
                crop="crop"
                enhan="enhanced"
                font="Arial Bold,54"
                interlace="interlace"
                tran="notransparent"
                [[ ! -z "${legend}" ]] && [[ ! "${key}" =~ "font" ]] && key="font 'Times Bold,50'${key:+;${key}}"
                [[ ! "${title}" =~ "font" ]] && title="${title:+${title} font 'Times Bold,80'}"
                linewidth="${linewidth:-2}"
                pointsize="${pointsize:-3}"
                if [ -z "${terminal}" ] ; then 
                    terminal="${term} ${interlace} ${crop} ${tran} ${enhan} font '${font}' size ${tsize} linewidth 5";
                fi 
            else
                if [ -z "${tsize}" ] ; then tsize="1080,720";fi
                if [ -z "${font}" ] ; then font="Arial,15";fi
                if [ -z "${fontscale}" ]; then fontscale="1.0"; fi
                if [ -z "${crop}" ]; then crop="crop";fi
                if [ -z "${enhan}" ]; then enhan="enhanced";fi
                if [ -z "${tran}" ]; then tran="notransparent";fi
                linewidth="${linewidth:-1.5}"
                pointsize="${pointsize:-1}"
                if [ -z "${terminal}" ] ; then 
                    terminal="${term} ${crop} ${tran} ${enhan} fontscale ${fontscale} font '${font}' size ${tsize} linewidth 1.2";
                fi 
            fi
            ;;
        *) 
            term="pngcairo";suffix=".png"; if [ -z "${terminal}" ] ; then  terminal="${term}";fi;;
    esac
    if [ -z "${open}" ]; then
        if [ ${TERM} == "linux" ]; then open="fbi"
        else open="display"; fi
    fi
    strpushv $prebuf ";" "set terminal push" "set terminal ${terminal}";
    if [ -z ${outfile} ] && [ ! -z ${infile} ] ; then outfile=$(pathpart -b ${infile});fi
    if [ -z ${outfile} ]; then outfile=${defaultoutfile};fi
    #if [ -f "${outfile}${suffix}" ]; then outfile="${outfile}`date +%Y%m%d%H%M%S`${suffix}";
    #else outfile="${outfile}${suffix}"; fi
    outfile="${outfile}${suffix}"
    strpush "set output '${outfile}'" $prebuf
    if [ ! -z "${samples}" ]; then strpush "set samples ${samples}" $prebuf;fi
    if [ ! -z "${isosamples}" ]; then strpush "set isosamples ${isosamples}" $prebuf;fi
    strpush "set encoding utf8" $prebuf 
    #if [ "${utf8}x" == "1x" ] ; then strpush "set encoding utf8" $prebuf; fi
    if [ ! -z "${dummy}" ]; then strpush "set dummy ${dummy}" $prebuf;fi
    if [ "${multiploton}x" == "1x" ] ; then strpush "set multiplot ${multiplot}" $prebuf;fi

    #====== match data with graph
    for ((i=0;i<${graphnumber};++i)) do
        # graph setting, pushed in $sslbuf
        if [ $i == 0 ] || [ "${multiploton}x" == "1x" ] ; then
            if [ ! -z "${functionstyle[$i]}" ] ; then strpush "set style function ${functionstyle[$i]}" $graphbuf; fi
            if [ "${parametric[$i]}x" == "1x" ] ; then strpush "set parametric" $graphbuf; fi
            if [ "${polaron[$i]}x" == "1x" ] ; then strpush "set polar" $graphbuf ; 
            elif [ "${polaron[$i]}x" == "0x" ];then strpush "unset polar" $graphbuf ;fi
            if [ ! -z "${angle[$i]}" ]; then strpush "set angles ${angle[$i]}" $graphbuf;fi
            if [ ! -z "${margins[$i]}" ]; then strpush "set margins ${margins[$i]}" $graphbuf;fi
            if [ ! -z "${origin[$i]}" ]; then strpush "set origin ${origin[$i]}" $graphbuf;fi
            if [ ! -z "${size[$i]}" ]; then strpush "set size ${size[$i]}" $graphbuf;fi
            if [ ! -z "${cntr[$i]}" ]; then strpush "set contour ${cntr[$i]}" $graphbuf;fi
            if [ ! -z "${view[$i]}" ] ; then strpush "set view ${view[$i]}" $graphbuf;fi
            if [ ! -z "${viewxyz[$i]}" ] ; then strpush "set view ${viewxyz[$i]}" $graphbuf;fi
            if [ "${surf[$i]}x" == "0x" ];then strpush "unset surf" $graphbuf;
            elif [ ! -z "${surf[$i]}" ] ; then strpush "set surf ${surf[$i]}" $graphbuf; fi
            if [ "${hidd[$i]}x" == "0x" ];then strpush "unset hidd" $graphbuf;
            elif [ "${hidd[$i]}x" == "1x" ];then strpush "set hidd" $graphbuf;
            elif [ ! -z "${hidd[$i]}" ]; then strpush "set hidd ${hidd[$i]}" $graphbuf;fi
            if [ "${palette[$i]}x" == "1x" ];then strpush "set palette" $graphbuf;
            elif [ ! -z "${palette[$i]}" ] ; then strpush "set palette ${palette[$i]}" $graphbuf;fi
            if [ ! -z "${pm3d[$i]}" ]; then
                if [ "${pm3d[$i]}x" == "1x" ];then strpush "set pm3d" $graphbuf;else
                    strpush "set pm3d ${pm3d[$i]}" $graphbuf;fi 
            fi
            if [ ! -z "${mapping[$i]}" ] ; then strpush "set mapping ${mapping[$i]}" $graphbuf ; fi
            if [ ! -z "${xyp[$i]}" ] ; then strpush "set xyplane ${xyp[$i]}" $graphbuf ; fi
            if [ "${fillpaton}x" == "1x" ] && [ -z "${fill[$i]}" ]; then fill{$[$i]}="pattern ${fillpat[$i]}";fi
            if [ ! -z "${grid[$i]}" ]; then eval strpush \"$(gnupara1 "${grid[$i]}" "grid")\"  $graphbuf;fi;
            if [ ! -z "${fill[$i]}" ] ; then strpush "set style fill ${fill[$i]}" $graphbuf; fi
            if [ ! -z "${hist[$i]}" ] ; then strpushv $graphbuf ";" "set style data histograms" "set style histogram ${hist[$i]}";fi
            if [ ! -z "${title[$i]}" ] ; then strpush "set title ${title[$i]}" $graphbuf ;fi
            if [ ! -z "${border[$i]}" ]; then eval strpush \"$(gnupara "${border[$i]}" "border")\"  $graphbuf;fi;
            if [ ! -z "${boxwidth[$i]}" ] ; then strpush "set boxwidth ${boxwidth[$i]}" $graphbuf; fi
            if [ ! -z "${zeroaxis[$i]}" ] ; then strpush "set ${zeroaxis[$i]}" $graphbuf; fi
            if [ ! -z "${cblim[$i]}" ]; then eval strpush \"$(gnupara "${cblim[$i]}" "cbrange")\"  $graphbuf;fi;
            if [ ! -z "${clrbx[$i]}" ]; then eval strpush \"$(gnupara01 "${clrbx[$i]}" "colorbox")\"  $graphbuf;fi;
            if [ ! -z "${cntrlabel[$i]}" ]; then eval strpush \"$(gnupara "${cntrlabel[$i]}" "cntrlabel")\"  $graphbuf;fi;
            if [ ! -z "${cntrparam[$i]}" ]; then eval strpush \"$(gnupara "${cntrparam[$i]}" "cntrparam")\"  $graphbuf;fi;
            if [ ! -z "${key[$i]}" ]; then eval strpush \"$(gnupara "${key[$i]}" "key")\"  $graphbuf;fi;
            if [ ! -z "${logscale[$i]}" ]; then eval strpush \"$(gnupara "${logscale[$i]}" "logscale")\"  $graphbuf;fi;
            if [ ! -z "${formatx[$i]}" ]; then strpush "set format x ${formatx[$i]}"   $graphbuf;fi;
            if [ ! -z "${formaty[$i]}" ]; then strpush "set format y ${formaty[$i]}"   $graphbuf;fi;
            if [ ! -z "${tlim[$i]}" ] ; then strpush "set trange ${tlim[$i]}" $graphbuf; fi
            if [ ! -z "${ulim[$i]}" ] ; then strpush "set urange ${ulim[$i]}" $graphbuf; fi
            if [ ! -z "${vlim[$i]}" ] ; then strpush "set vrange ${vlim[$i]}" $graphbuf; fi
            if [ ! -z "${xlim[$i]}" ]; then eval strpush \"$(gnupara "${xlim[$i]}" "xrange")\"  $graphbuf;fi;
            if [ ! -z "${ylim[$i]}" ]; then eval strpush \"$(gnupara "${ylim[$i]}" "yrange")\"  $graphbuf;fi;
            if [ ! -z "${x2lim[$i]}" ] ; then strpush "set x2range ${x2lim[$i]}" $graphbuf; fi
            if [ ! -z "${y2lim[$i]}" ] ; then strpush "set y2range ${y2lim[$i]}" $graphbuf; fi
            if [ ! -z "${zlim[$i]}" ] ; then strpush "set zrange ${zlim[$i]}" $graphbuf; fi
            if [ ! -z "${rtic[$i]}" ]; then eval strpush \"$(gnupara "${rtic[$i]}" "rtics")\"  $graphbuf;fi;
            if [ ! -z "${tic[$i]}" ]; then eval strpush \"$(gnupara "${tic[$i]}" "tics")\"  $graphbuf;fi;
            if [ ! -z "${xtic[$i]}" ]; then eval strpush \"$(gnupara "${xtic[$i]}" "xtics")\"  $graphbuf;fi;
            if [ ! -z "${ytic[$i]}" ]; then eval strpush \"$(gnupara "${ytic[$i]}" "ytics")\"  $graphbuf;fi;
            if [ ! -z "${ztic[$i]}" ]; then eval strpush \"$(gnupara "${ztic[$i]}" "ztics")\"  $graphbuf;fi;
            if [ ! -z "${x2tic[$i]}" ]; then eval strpush \"$(gnupara "${x2tic[$i]}" "x2tics")\"  $graphbuf;fi;
            if [ ! -z "${y2tic[$i]}" ]; then eval strpush \"$(gnupara "${y2tic[$i]}" "y2tics")\"  $graphbuf;fi;
            if [ ! -z "${x2mtic[$i]}" ]; then eval strpush \"$(gnupara "${x2mtic[$i]}" "mx2tics")\"  $graphbuf;fi;
            if [ ! -z "${y2mtic[$i]}" ]; then eval strpush \"$(gnupara "${y2mtic[$i]}" "my2tics")\"  $graphbuf;fi;
            if [ ! -z "${xlabel[$i]}" ]; then eval strpush \"$(gnupara "${xlabel[$i]}" "xlabel")\"  $graphbuf;fi;
            if [ ! -z "${x2label[$i]}" ]; then eval strpush \"$(gnupara "${x2label[$i]}" "x2label")\"  $graphbuf;fi;
            if [ ! -z "${ylabel[$i]}" ]; then eval strpush \"$(gnupara "${ylabel[$i]}" "ylabel")\"  $graphbuf;fi;
            if [ ! -z "${y2label[$i]}" ]; then eval strpush \"$(gnupara "${y2label[$i]}" "y2label")\"  $graphbuf;fi;
            # ====== auxillary information, including arrows,labels, objects
            if [ ! -z "${arrow[$i]}" ]; then eval strpush \"$(gnupara "${arrow[$i]}" "arrow")\"  $graphbuf;fi;
            if [ ! -z "${label[$i]}" ]; then eval strpush \"$(gnupara "${label[$i]}" "label")\"  $graphbuf;fi;
            if [ ! -z "${object[$i]}" ]; then eval strpush \"$(gnupara "${object[$i]}" "object")\"  $graphbuf;fi;
        fi
        # assembling data from data file or expression( including user-defined functions, refer -F)
        # data file can provide: detail data file control, including index, column, row(block), 
        #                        otherwise, whole data block is given, similar with expression
        if [ "${multiploton}x" == "1x" ]; then datablock= ;fi
        if [[ "${datamode}" =~ "data" ]] &&  [ -z "${data[$i]}" ]; then  
            if [ "${xycol[$i]}x" != "0x" ]; then
                if [ -z "${xycol[$i]}" ] ; then 
                    if [ -z "${secondcol[$i]}" ] ; then # data column
                        if [ "${firstcol}x" == "0x" ];then # one column
                            if [ $i -eq 0 ] ; then secondcol=1; else secondcol[$i]=$((${secondcol[$(($i-1))]}+1)); fi
                        else 
                            secondcol[$i]=$((${firstcol[$i]}+1)); 
                        fi
                    fi
                    xycol[$i]="i ${indexnum[$i]:-0} u ${firstcol[$i]:+${firstcol[$i]}:}${secondcol[$i]} ${row[$i]:+ every ${row[$i]}}"
                else
                    xycol[$i]="i ${indexnum[$i]:-0} u ${xycol}"
                fi
                data[$i]="${data[$i]} ${xycol[$i]}"
            fi
        fi
        # binding with linemode and legend, all in "datablock" buffer for one graph
        if [[ "${data[$i]}" =~ ";" ]] ; then # multiple lines for one graph
            unset datap;strsplit "${data[$i]}" ";" datap
            for((iline=0;iline<${#datap[@]};++iline)) do
                #[[ ! "${linemode[$linenum]}" =~ "lt" ]] && linemode[$linenum]="${linemode[$i]:+w ${linemode[$linenum]}}";
                linemode[$linenum]="w ${linemode[$i]:+ ${linemode[$linenum]}}";
                if [ "${linestyleindex[$linenum]}x" != "0x" ]; then
                    linemode[$linenum]="${linemode[$linenum]} ls ${linestyleindex[$linenum]:-$[${linenum}+1]}"
                fi
                legendi='notitle'; if [ ! -z "${legend[$[$linenum]]}" ] ; then legendi="title '${legend[$linenum]}'"; fi
                if [[ "${datamode}" =~ "data"  ]];then
                    datablock="${datablock:+${datablock},}'${infile[$linenum]}' ${datap[$iline]} ${linemode[$linenum]} ${legendi}";
                else
                    datablock="${datablock:+${datablock},}${datap[$iline]} ${linemode[$linenum]} ${legendi}";
                fi
                linenum=$[$linenum+1]
            done
        else 
            if [ ! -z "${linemode[$linenum]}" ]; then linemode[$linenum]="w ${linemode[$linenum]}";fi
            if [ "${linestyleindex[$linenum]}x" != "0x" ]; then
                linemode[$linenum]="${linemode[$linenum]} ls ${linestyleindex[$linenum]:-$[${linenum}+1]}"
            fi
            legendi='notitle'; if [ ! -z "${legend[$[$linenum]]}" ] ; then legendi="title '${legend[$linenum]}'"; fi
            if [[ "${datamode}" =~ "data"  ]];then
                if [ -z "${infile[$linenum]}" ]; then infile[$linenum]="${infile[$[$linenum-1]]}";fi
                datablock="${datablock:+${datablock},}'${infile[$linenum]}' ${data[$linenum]} ${linemode[$linenum]} ${legendi}";
            else
                datablock="${datablock:+${datablock},}${data[$linenum]} ${linemode[$linenum]} ${legendi}";
            fi
            linenum=$[$linenum+1]
        fi
        # bind graph setting $graphbuf and "datablock" together, pushed in $databuf
        if [ "${multiploton}x" == "1x" ] ; then 
            strpushv $databuf ";" "${!graphbuf}" "${plotengine} ${datablock}";unset $graphbuf;
        elif [ ${graphnumber} -eq $[$i+1] ]; then
            strpushv $databuf ";" "${!graphbuf}" "${plotengine} ${datablock}";
        fi
    done

    # line type details, pushed in $prebuf
    if [ "${linestyleindex}x" == "0x" ]; then linestylenum=0;
    elif [ -z "${linestylenum}" ]; then linestylenum=${linenum};fi
    for((i=0;i<${linestylenum};++i)) do
        # dash type, provide builtin type [1,2,3,...] or customized type (2,4,4,7),".. ", or (2,5,2,15)
        # dash type  is binded by line type
        if [[ "${dashtype[$i]}" =~ [:digit:] ]]; then  dashtypeindex[$i]=${dashtype[$i]};
        elif [ ! -z "${dashtype[$i]}" ]; then linetypeindex[$i]=${linetypeindex[$i]:-$[$i+1]};
            strpush "set dt $[$i+1] ${dashtype[$i]}" $prebuf;
            strpush "set linetype ${linetypeindex[$i]} dt $[$i+1]" $prebuf
        fi
        #line style: user-defiined or default value
        #        set line style, can setting totally by linestyle, directly pushed into  buffer $prebuf
        #        and line details, including linetype, linewidth, line color, point type, point size,...
        if [ $i -gt 0 ] && [ -z "${linecolor[$i]}" ] && [ "${multiploton}x" == "1x" ]; then linecolor[$i]="${linecolor[$[$i-1]]}";fi
        if [ $i -gt 0 ] && [ -z "${linewidth[$i]}" ]; then linewidth[$i]="${linewidth[$[$i-1]]}";fi
        if [ $i -gt 0 ] && [ -z "${pointsize[$i]}" ]; then pointsize[$i]="${pointsize[$[$i-1]]}";fi
        if [ -z "${linestyle[$i]}" ] ; then 
            linestyle[$i]=$(strcat "${linetypeindex[$i]:+ lt ${linetypeindex[$i]}}" \
            "${linewidth[$i]:+ lw ${linewidth[$i]}}" "${linecolor[$i]:+ lc ${linecolor[$i]}}" \
            "${pointtype[$i]:+ pt ${pointtype[$i]}}" "${pointsize[$i]:+ ps ${pointsize[$i]}}" \
            "${dashtypeindex[$i]:+ dt ${dashtypeindex[$i]}}")
        fi
        if [ -z "${linestyleindex[$i]}" ] || [ "${linestyleindex[$i]}x" == "0x" ]; then linestyleindex[$i]=$[$i+1];fi
        if [ ! -z "${linestyle[$i]}" ] ; then strpush "set style line ${linestyleindex[$i]} ${linestyle[$i]}" $prebuf;
        elif [ "${multiploton}x" == "1x" ] || [ $linestylenum -eq 0 ]; then
            strpush "set style line ${linestyleindex[$i]} lt -1 lw 2" $prebuf
        else strpush "set style  line ${linestyleindex[$i]} lt $[$i+1] lw 2" $prebuf;fi
    done
    # ====== post configuration, pushed in $postbuf 
    if [ "${multiploton}x" == "1x" ] ; then strpush "unset multiplot" $postbuf;fi
    strpushv $postbuf ";"  "set output" "set terminal pop"

    #=======  check data mode
    case "${datamode}" in
        "command")
            strpushv $buf ";" "${!funcbuf}" "${!prebuf}" "${!cmdbuf}" "${!postbuf}"
            cmd='gnuplot <(echo "${!buf}")';;
        "expression"|data*)
            strpushv $buf ";" "${!funcbuf}" "${!prebuf}" "${!databuf}" "${!postbuf}" 
            cmd='gnuplot <(echo "${!buf}")';;
        "flush")
            cmd='unset $buf; unset $cmdbuf;unset $databuf;unset $funcbuf;'
            cmd="${cmd}"'unset $graphbuf;unset $prebuf;unset $postbuf; unset $testbuf';;
        "help")
            cmd='gnuplot -e "help ${showhelp}" 2>&1 |less';;
        "thishelp")
            cmd='echo "${_HELP_}"|less';;
        "script")
            [ ! -z "${script}" ]  && cmd='gnuplot <(cat ${script[@]})';;
        "show")
            cmd='gnuplot -e "show ${showhelp}" 2>&1 |less';;
        "test") 
            case "${testtype}" in
                "term")strpushv $testbuf ";" "test";;
                "pal"|"pltt"|"palette") strpushv $testbuf ";" "test palette";;
                "as"|"arrow"|"arrowstyle") 
                    local assyntax=$(strcat "set arrow <tag> {nohead | head | backhead | heads}" \
                        "\n{size <headlength>,<headangle>{,<backangle>}}" "\n{filled | empty | nofilled | noborder}")
                    strpushv $testbuf ";" "ars='head nohead backhead heads empty filled nofilled noborder backangle headangle headlength reference '" \
                    "clrs=\"blue green red black\"" \
                    'set style arrow 1 lt -1 lw 2 head' \
                    'set style arrow 2 lt -1 lw 2 nohead' \
                    'set style arrow 3 lt -1 lw 2 backhead' \
                    'set style arrow 4 lt -1 lw 2 heads' \
                    'set style arrow 5 lt -1 lw 2 heads empty' \
                    'set style arrow 6 lt -1 lw 2 heads filled' \
                    'set style arrow 7 lt -1 lw 2 nofilled' \
                    'set style arrow 8 lt -1 lw 2 noborder' \
                    'set style arrow 9 lt -1 lw 2 lc rgb "blue"  heads size screen 0.085,45,30 ' \
                    'set style arrow 10 lt -1 lw 2 lc rgb "green" heads size screen 0.065,45,45 ' \
                    'set style arrow 11 lt -1 lw 2 lc rgb "red" heads size screen 0.045,30,45 ' \
                    'set style arrow 12 lt -1 lw 2 heads size screen 0.025,30,45 ' \
                    "set label sprintf(\"%s\",\"${assyntax}\") at -400,-5;" \
                    "set for [i=1:8] arrow from -500, (-40- i * 8) to 500, (-40 - i * 8) as i" \
                    "set for [i=1:8] label sprintf('%s',word(ars,i)) at -540, (-40 - i * 8) right" \
                    "set for [i=9:12] arrow from -500, (-40- 11 * 8) to 500, (-40 - 11 * 8) as i" \
                    "set for [i=9:12] label sprintf('%s',word(ars,i)) at -580+(i-8)*200, (-40 - 9.5 * 8) front tc rgb word(clrs,i-8)" \
                    "unset tics;plot [-1000:1000] [-180:0] -1001 notitle";;
            "enhance"|"enhan"|"enhanced") strpushv $testbuf ";" 'save_encoding = GPVAL_ENCODING' 'set encoding utf8' \
                    'set title "Demo of enhanced text mode using a single UTF-8 encoded font \nThere is another demo that shows how to use a separate Symbol font"' \
                    'set xrange [-1:1]' 'set yrange [-0.5:1.1]' 'set format xy "%.1f"' \
                    'set arrow from  0.5, -0.5 to  0.5, 0.0 nohead' 'set label 1 at -0.65, 0.95' \
                    'set label 1 "Superscripts and subscripts:" tc lt 3' 'set label 3 at -0.55, 0.85' \
                    'set label 3 "A_{j,k} 10^{-2}  x@^2_k    x@_0^{-3/2}y"' 'set label 5 at -0.55,  0.7 ' \
                    'set label 5 "Space-holders:" tc lt 3' 'set label 6 at -0.45, 0.6 ' \
                    'set label 6 "<&{{/=20 B}ig}> <&{x@_0^{-3/2}y}> holds space for"' \
                    'set label 7 at -0.45, 0.5 ' 'set label 7 "<{{/=20 B}ig}> <{x@_0^{-3/2}y}>"' \
                    'set label 8 at -0.9, -0.2' 'set label 8 "Overprint \n(v should be centred over d)" tc lt 3' \
                    'set label 9 at -0.85, -0.4' 'set label 9 " ~{abcdefg}{0.8v}"' \
                    'set label 10 at  -.40, 0.35' 'set label 10 "UTF-8 encoding does not require Symbol font:" tc lt 3' \
                    'set label 11 at -.30, 0.2' 'set label 11 "{/*1.5 ∫@_{/=9.6 0}^{/=12 ∞}} {e^{-{μ}^2/2} d}{μ=(π/2)^{1/2}}"' \
                    'set label 21 at 0.5, -.1' 'set label 21 "Left  ^{centered} ƒ(αβγδεζ)" left' \
                    'set label 22 at 0.5, -.2' 'set label 22 "Right ^{centered} ƒ(αβγδεζ)" right' \
                    'set label 23 at 0.5, -.3' 'set label 23 "Center^{centered} ƒ(αβγδεζ)" center' \
                    'set label 30 at -.9, 0.0 "{/:Bold Bold} and {/:Italic Italic} markup"' \
                    'set key title " "' 'plot sin(x)**2 lt 2 lw 2 title "sin^2(x)"' 'set encoding save_encoding' 
                    ;;
                "dash")
                    local dash1111=$(strcat 'plot cos(x) lt -1 pi -4 pt 6 title "pi -4 pt 6",' \
                        'cos(x-.8)  lt -1 pi -3 pt 7 ps 0.2 title "pi -3 pt 7 ps 0.2",' \
                        'cos(x-.2)  lt -1 pi -6 pt 7 title "pi -6 pt 7",' \
                        'cos(x-.4)  lt -1 pi -3 pt 4 title "pi -3 pt 4",' \
                        'cos(x-.6)  lt -1 pi -5 pt 5 title "pi -5 pt 5",' \
                        'cos(x-1.)  with line lt -1 title "lt -1",' \
                        'cos(x+.2)  with line lt -1 lw 2 title "lt -1 lw 2"')
                    strpushv  $testbuf ";" "set style function linespoints" \
                    'set title "The pointinterval property is another way to create interrupted lines"' \
                    'set xlabel "This technique works best for equally spaced data points" ' \
                    'set xrange [ -0.500000 : 3.30000 ] noreverse nowriteback' \
                    'set yrange [ -1.00000 : 1.40000 ] noreverse nowriteback'  'set bmargin  6'  \
                    "${dash1111}"
                    ;;
            esac
            strpushv $buf ";" "${!prebuf}" "${!testbuf}" "${!postbuf}"
            cmd='gnuplot <(echo "${!buf}"); ${open} ${outfile} &> /dev/null';;
    esac
    if [ "${debugon}x" == "1x" ]; then cmd='echo "#!/bin/gnuplot;# author: Ainray;# date: `date`;;${!buf}"|sed "s/;/\n/g"|less';
    else
        case "${datamode}" in  # direct open in terminal
            "command"|"expression"|data*)
                # convert eps to pdf and png
                if [ "${term}" == "epscairo" ]; then
                    cmd="${cmd};"'gs -o -q -sDEVICE=png256 -dEPSCrop -r600 -o${outfile%${suffix}}_eps.png ${outfile} >/dev/null'
                elif [ "${term}" == "pdfcairo" ]; then
                    cmd="${cmd};"'gs -o -q -sDEVICE=png256 -dPDFCrop -r600 -o${outfile%${suffix}}_pdf.png ${outfile} >/dev/null'
                fi
                if [ "${quiet}x" != "1x" ]; then
                    if [ "${term}" == "epscairo" ]; then
                        cmd="${cmd};"'${open} ${outfile%${suffix}}_eps.png &> /dev/null'
                    elif [ "${term}" == "epscairo" ]; then
                        cmd="${cmd};"'${open} ${outfile%${suffix}}_pdf.png &> /dev/null'
                    else
                    cmd="${cmd};"'${open} ${outfile} &> /dev/null'
                    fi
                fi
            ;;
        esac
    fi
    [ "${datamode}" != "flush" ] && cmd="${cmd};"'unset $buf; unset $cmdbuf;unset $databuf;unset $funcbuf;' \
            && cmd="${cmd}"'unset $graphbuf;unset $prebuf;unset $postbuf; unset $testbuf'
    eval ${cmd}
}
