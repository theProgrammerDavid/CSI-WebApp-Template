#!/bin/env bash

node=0
django=0

CSIUnixDir=~/.CSI-WebApp-Template/Unix

#If operation is generate or gen
if [[ $1 =~ "generate" ]] || [[ $1 =~ "gen" ]]
then
    if [[ $# -gt 3 ]]
    then
        echo "Too many arguments!"
        exit 1
    fi
    project_name=$3
    #If option is --node or -n
    if [[ $2 =~ "--node" ]] || [[ $2 =~ "-n" ]]
    then
        node=1

    #If option is --django or -d
    elif [[ $2 =~ "--django" ]] || [[ $2 =~ "-d" ]]
    then
        django=1

    #If the option is any this else
    else
        echo "Invalid request to generate. Choose --node or --django."
    fi

#If the operation is --help or -h
elif [[ $1 =~ "--help" ]] || [[ $1 =~ "-h" ]]
then
    help=1

#If the operation is --version or -v
elif [[ $1 =~ "--version" ]] || [[ $1 =~ "-v" ]]
then
    echo "1.0.0"

#If the operation is --delete or -D
elif [[ $1 =~ "--delete" ]] || [[ $1 =~ "-D" ]]
then
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        if [[ ! -z "$2" ]]
        then
            ls -a | grep $2 && rm -rf $2 || echo "'$2' not found."
        else
            "Project to be deleted not specified."
            exit 1
        fi
    else
        echo "No files were deleted."
        exit 1
    fi

#If the operation is --reset or -r
elif [[ $1 =~ "--reset" ]] || [[ $1 == "-r" ]]
then
    echo
    read -p "This will delete the current directory. Are you sure you are in the right directory? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        delete_dir="$(basename "$PWD")"
        if [[ -f server.js ]]
        then
            cd ..
            rm -r $delete_dir
            echo "Rebuilding Node Template... "
            node=1
        elif [[ -f manage.py ]]
        then
            cd ..
            rm -r $delete_dir

            if [[ -d "venv" ]]
            then
                echo
                read -p "Do you also want to remove the venv directory in `pwd` (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]
                then
                    rm -r venv
                fi
            fi
            echo "Rebuilding Django Template... "
            django=1
        else
            echo
            echo "Unable to determine wheter it is a Django or a Node project. Delete using 'csi-cli -D' and re-create your project."
        fi
    fi

#To update the CLI
elif [[ $1 =~ "--update" ]] || [[ $1 =~ "-u" ]]
then
    cd $CSIUnixDir
    git pull
    if [[ -f /usr/bin/csi-cli ]]
    then
        sudo rm /usr/bin/csi-cli
    fi
    cd tools
    cat generate.sh > csi-cli
    chmod +x csi-cli
    sudo cp csi-cli /usr/bin/
    rm csi-cli
#For any other option
else
    echo "Invalid arguments."
    echo
    help=1
fi

#To create a Node-js project
if [[ $node -eq 1 ]]
then
    if [[ -z "$project_name" ]]
    then
        echo "Missing project name."
        echo "Creating project named NodeProject"
        project_name="NodeProject"
    fi

    echo "Making directories..."
    mkdir $project_name
    cd $project_name

    #Making the directories in the following line
    mkdir config partials static static/images static/fonts static/css static/js

    #Making the files in the following lines
    touch server.js

    echo "Copying files ..."
    npm init
    #Copying files to the directory
    cat $CSIUnixDir/Node/server.js > server.js
    cat $CSIUnixDir/Node/package-lock.json > package-lock.json

    cp -r $CSIUnixDir/Node/models models
    cp -r $CSIUnixDir/Node/views views
    cp -r $CSIUnixDir/Node/node_modules node_modules
    cp -r $CSIUnixDir/Node/routes routes

    #Template Created
    if [[ $? -eq 0 ]]
    then
        echo "Complete. Node Template was created successfully."
    else
        echo "Error in file creation. Note that CSIUnixDir must be set to path/to/directory/.CSI-WebApp-Template/Unix"
    fi
fi

#To create a Django project
if [[ $django -eq 1 ]]
then
    if [[ -z "$project_name" ]]
    then
        echo "Missing project name."
        echo "Creating project named django_project"
        project_name="django_project"
    fi
    echo "Making directories..."

    echo "Not creating a virtual environment might cause problems later."
    read -p "Do you want to create a virtual environment? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        virtualenv venv
        if [[ $? -ne 0 ]]
        then
            echo "Python or pip is not installed on your computer, or is not added to PATH. Try again after configuring pip."
            exit 1
        fi
        echo "Remember to execute: "
        echo "  source venv/bin/activate"
        echo "everytime before you run your web-app."
    fi

    #Calls django-admin to start project creation
    django-admin startproject $project_name

    if [[ $? -eq 0 ]]
    then
        cd $project_name
        app_name="django_app"
        read -p "Enter the app name: " -r
        app_name=$REPLY
        django-admin startapp $app_name
        if [[ $? -ne 0 ]]
        then
            read -p "Do you want to restart project creation? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]
            then
                csi-cli --reset
            else
                exit 1
            fi
        fi

        touch $app_name/urls.py

        cat $CSIUnixDir/Django/django_project/django_project/settings.py > $project_name/settings.py
        cat $CSIUnixDir/Django/django_project/django_project/urls.py > $project_name/urls.py

        sed -i "s/django_app/$app_name/g" $project_name/*.py #Replace all instances of django_app in $project_name/*.py




    else
        echo "Django is not installed or is not added to PATH on your computer, or your project name is invalid."
        read -p "Do you want to install django? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            pip install django
            if [[ $? -ne 0 ]]
            then
                echo "Python or pip is not installed on your computer, or is not added to path. Try again after configuring pip."
                exit 1
            fi
        else
            echo "No files were created."
            exit 1
        fi
    fi
fi

#Help Menu
if [[ $help -eq 1 ]]
then
    echo "usage: csi-cli <operation> <option>"
    echo "operations:"
    echo
    echo "  csi-cli {-h --help}: Help"
    echo "  csi-cli {gen generate} {-n --node} your-project-name: Generate Node-js Template"
    echo "                         {-d --django} your-project-name: Generate Django Template"
    echo "  csi-cli {-D --delete} your-project-name: Delete Project"
    echo "  csi-cli {-r --reset}: Reset All Changes Made to Template"
    echo "  csi-cli {-u --update}: Updates the csi-cli"
    echo
    echo "Note: {x y} implies you can use 'csi-cli x' or 'csi-cli y'"
    echo "If 'project-name' is empty, csi-cli assumes you are inside the directory."
fi
