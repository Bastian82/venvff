function venvff
  set -g cmd 'virtualenv'
  set -g current_dir (echo $PWD)
  set -g venvff_dir $HOME/.venvff
  set -g venvff_tmp /tmp/venvff.tmp

  function exists
    if [ -d $argv[1] ]; and [ -e $argv[1] ]
     set_color red
     echo "Virtualenv $argv[1] already exists"
     set_color normal
     exit 1
    end
  end

  function create
    set desc $argv[1]
    set params $argv[2]
    set name $argv[3]
    mkdir -p $venvff_dir; and cd $venvff_dir
    if [ $params != 'none' ]
      set splited_params (string split ";" $params)
      set splited_params_m
      for s in splited_params
        set splited_params_m "--"$splited_params 
      end
      set cmd $cmd[1]" $splited_params_m"
      echo 'params>'$splited_params >> $venvff_tmp
    else
      echo 'params>' >> $venvff_tmp
    end
    if [ $desc != 'none' ]
      echo 'desc>'$desc >> $venvff_tmp
    else
      echo 'desc>' >> $venvff_tmp
    end
    exists $name
    eval $cmd $name
    if [ -e $venvff_tmp ]
      mv $venvff_tmp $venvff_dir/$name/.venff_meta
    end
    echo 'created>'(date "+%F %T") >> $venvff_dir/$name/.venff_meta
    echo 'last>' >> $venvff_dir/$name/.venff_meta
    cd $current_dir
  end

  function workon
    set name $argv[1]
    set date (date "+%F %T")
    set r "s/last>.*/last>"$date"/g"
    sed -i -E $r $venvff_dir/$name/.venff_meta
    source $venvff_dir/$name/bin/activate.fish
  end
  
  function destroy
    set name $argv[1]
    set check (echo $VIRTUAL_ENV |grep -E '/'$name'$')
    if [ $status -ne 0 ]
      rm -rf $venvff_dir/$name
    else
      set_color red
      echo "Cannot destroy active virtualenv. Deativate it first"
      set_color normal
    end
  end

  function list
    printf '%s|%s|%s|%s|%s' NAME DESC PARAMS CREATED LAST > $venvff_tmp
    echo '' >> $venvff_tmp
    for dir in (ls -tr $venvff_dir)
      set descx '-'
      set paramsx '-'
      set name $dir
      set desc_full (grep desc $venvff_dir/$name/.venff_meta)
      set desc (string split ">" $desc_full)
      if [ (string length  $desc[2]) -ne 0 ]  
        set descx $desc[2]
      end
      set params_full (grep params $venvff_dir/$name/.venff_meta)
      set params (string split ">" $params_full)
      if [ (string length  $params[2]) -ne 0 ]  
        set paramsx $params[2]
      end
      set created_full (grep created $venvff_dir/$name/.venff_meta)
      set created (string split ">" $created_full)[2]
      set last_full (grep last $venvff_dir/$name/.venff_meta)
      set last (string split ">" $last_full)[2]
      printf '%s|%s|%s|%s|%s' $name $descx $paramsx $created $last >> /tmp/venvff.tmp
      echo '' >> $venvff_tmp
    end
    column -t -s"|" $venvff_tmp
    rm $venvff_tmp
  end

  function printHelp
    switch $argv[1]
      case 'create'
        echo "Optional parameters:"
        echo "--desc     -describe new virtual environment"
        echo "--params   -provide additional options provided by virtualenv, separated by semicolon provided by virtualenv. For example 'python=python3.5;no-download;no-pip'"
      case '*'
        echo "Usage: venvff [-h|--help] [--optional] [positional] [NAME]"
        echo "Python virtualenv management for fish shell"
        echo "Positional parameters:"
        echo "create    --create new virtual environment"
        echo "destroy   --destroy virtual environment"
        echo "workon    --switch virtual environment"
	echo "exit      --deactivate current virtual environment"
        echo "list      --list virtual environments"
    end
  end

  switch $argv[1]
    case '--help'
       printHelp dummy
    case '-h'
       printHelp dummy
    case 'create'
       set desc 'none'
       set params 'none'
       if [ $argv[2] = '--help' ]
         printHelp 'create'
	 return 0
       else if [ $argv[2] = '-h' ]
         printHelp 'create'
	 return 0
       else if [ $argv[2] = '--params' ];and [ $argv[4] != '--desc' ]
         set params $argv[3] 
         set name $argv[4]
       else if [ $argv[2] = '--desc' ];and [ $argv[4] != '--params' ]
         set desc $argv[3]
         set name $argv[4]  
       else if [ $argv[2] = '--desc' ];and [ $argv[4] = '--params' ]
         set desc $argv[3]
         set params $argv[5]
         set name $argv[6]
       else if [ $argv[2] = '--params' ];and [ $argv[4] = '--desc' ]
         set desc $argv[5]
         set params $argv[3]
         set name $argv[6]
       else
         set name $argv[2]
       end
       create $desc $params $name 
    case 'workon'
      set name $argv[2]
      workon $name
    case 'exit'
      deactivate
    case 'list'
      list
    case 'destroy'
      set name $argv[2]
      destroy $name
    case '*'
       echo "Missing parameters"
  end
end
