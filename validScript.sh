#!/bin/bash


# En-tête d'accueil de l'utilisateur
echo "==============================
      Virtua 3000             |
Interface de gestion de box   |
==============================
";

echo "Bienvenue sur Virtua 3000 ! Ici vous pourrez rapidement mettre en place
un environnement virtuel pour tester vos projets !";

# Vérification de la présence d'un Vagrantfile à l'emplacement du script
if [ ! -f Vagrantfile ]; then
    vagrant init 1> /dev/null
    echo "Un fichier Vagrantfile basique a été généré !
Merci de choisir les options de configuration"
else
  # On propose de conserver/détruire le Vagrantfile précédent, au cas où il existe.
    echo "Un fichier Vagrantfile existe déjà dans ce dossier !"
    echo -e "1/ Conserver"
    echo -e "2/ Supprimer"
    read -p "Choix :" clear
      case $clear in # gérer le retour au début
        1)
        echo "Merci d'enregistrer le Vagrantfile dans un autre dossier."
        exit 1
        ;;
        2)
        rm Vagrantfile
        echo "Suppression du Vagrantfile effectuée ! Nouveau Vagrantfile crée."
        vagrant init
        ;;
      esac
fi

# On liste les différentes box
echo
echo "Veuillez choisir votre box :"
echo -e "\t 1. ubuntu/xenial64"
echo -e "\t 2. ubuntu/trusty64"
read -p "Choix : " box
echo

case $box in
    # choix de la box xenial64
    1)
    sed -i -e 's/base/ubuntu\xenial64/g' Vagrantfile
    echo "La box ubuntu/xenial64 sera téléchargée au lancement de la machine virtuelle."
    ;;
    # choix de la box trusty64
    2)
    sed -i -e 's/base/ubuntu\/trusty64/g' Vagrantfile
    echo "La box ubuntu/trusty64 sera téléchargée au lancement de la machine virtuelle."
    ;;

    # en cas de saisie non reconnue, on arrête la création, on appelle la police.
    *)
    echo "Choix non reconnu. Interruption du procesus."
    echo "Annulation du processus de génération de Vagrantfile..."
    echo "Cet incident a été reporté."
    echo "..."
    sleep 2
    echo "..."
    sleep 2
    echo "..."
    sleep 2
    echo "Les forces de l'ordre sont en route, merci de rester assis face à votre poste."
    echo "Toute l'équipe de Virtua 3000 vous souhaite une agréable journée !"
    rm Vagrantfile
    exit 1
    ;;
esac

# Création du fichier shared folder en local
echo "Création du dossier partagé en local."
read -p "Nom du dossier à créer : " localFolder
  # Vérification du nom du dossier saisi
  if [ ! -d "$localFolder" ]; then
      echo "Création du dossier host $localFolder"
      mkdir $localFolder
    fi

  if [[ $localFolder =~ ^(/)?([^/\0]+(/)?)+$ ]]; then
      echo "Personnalisation du dossier local $localFolder"
      echo
      # configuration du chemin local
      sed -i -e "s,../data,$localFolder,g" Vagrantfile
      sed -i "/synced_folder/s/^  # /  /g" Vagrantfile
  else
      echo "Il y a une erreur dans le nom de dossier."
      echo "Arrêt total de la création du Vagrantfile. Merci de réessayer."
      rm Vagrantfile
      exit 1
  fi

  # Création du fichier distant de la VM
  echo "Création du fichier partagé distant (chemin absolu + dossier,
  ex : /var/www ou /toto/src )."
  read -p "Nom du dossier guest : " sharedFolder
  if [[ $sharedFolder =~ ^(/)?([^/\0]+(/)?)+$ ]]; then
      echo "Personnalisation du dossier guest $sharedFolder"
      echo
      sed -i -e "s,/vagrant_data,$sharedFolder,g" Vagrantfile
  # En cas d'erreur de l'utilisateur
  else
      echo "Il y a une erreur dans le nom de dossier."
      echo "Arrêt total de la création du Vagrantfile. Merci de réessayer."
      rm Vagrantfile
      exit 1
  fi

# On configure le réseau privé. Les messages sont là pour occuper l'utilisateur
  echo "Configuration en cours ..."
  sed -i "/private_network/s/^  # /  /g" Vagrantfile
  echo "..."
  sleep 2
  echo "Réseau local établi."
  sleep 1

# On lance le Vagrant Up en y mettant les formes
  echo "Mise en place de l'environnement de travail. Merci de patienter !"
  sleep 2
  vagrant up
  vagrant up
  clear

# Tout est en place, on lance le listing des machines virtuelles. Ou pas.
  echo "Environnement de travail mis en place !"

  echo -e "\t 1. Lister les machines virtuelles existantes"
  echo -e "\t 2. Passer à l'étape suivante"
  echo -e "\t 3. Quitter l'assistant"
  read -p "Choix : " list

  case $list in
    1) vagrant global-status ;;
    2) sleep 1
    echo "..."
    sleep 1 ;;
    *) echo "Fin de tâche. Fermeture de l'assistant Virtua 3000."
    exit 1
    ;;
  esac

  sleep 2
  read -p "Lancer la connexion SSH ? Y/N" connection;
  case $connection in
    y) vagrant ssh ;;
    n) exit 1
    ;;
  esac
