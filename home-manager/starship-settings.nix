{
  "$schema" = "https://starship.rs/config-schema.json";
  format = "[](color_teal)$container$directory[](fg:color_teal bg:color_brightgreen)$rust$golang$python$helm$package[](fg:color_brightgreen bg:color_yellow)$git_branch$git_commit$git_state$git_status[](fg:color_yellow bg:color_brightorange)$kubernetes[](fg:color_brightorange)$cmd_duration$line_break$character";
  add_newline = true;
  palette = "srcery";
  palettes = {
    srcery = {
      color_bg0 = "#1c1b19";
      color_bg1 = "#121212";
      color_blue = "#2c78bf";
      color_brightblack = "#918175";
      color_brightblue = "#68a8e4";
      color_brightcyan = "#2be4d0";
      color_brightgreen = "#98bc37";
      color_brightmagenta = "#ff5c8f";
      color_brightorange = "#ff8700";
      color_brightred = "#f75341";
      color_brightyellow = "#fed06e";
      color_fg0 = "#fce8c3";
      color_green = "#519f50";
      color_magenta = "#e02c6d";
      color_orange = "#ff5f00";
      color_red = "#ef2f27";
      color_teal = "#008080";
      color_xgray1 = "#262626";
      color_yellow = "#fbb829";
    };
  };
  container = {
    style = "bg:color_teal fg:color_yellow";
    format = "[\\[$name\\] ]($style)";
  };
  directory = {
    style = "bg:color_teal";
    read_only_style = "bg:color_teal fg:color_brightorange";
    read_only = "󰌾 ";
    format = "[$path ]($style)[$read_only]($read_only_style)";
    substitutions = {
      ".config" = " ";
      Arbeit = "󰻡 ";
      Bewerbungen = "󰉌 ";
      Bilder = " ";
      Dokumente = "󰲂 ";
      Downloads = " ";
      Musik = "󰝚 ";
      Netzwerk = " ";
      Nextcloud = "󰅟 ";
      Studium = " ";
      Technik = " ";
      Uni = " ";
    };
  };
  git_branch = {
    disabled = false;
    only_attached = true;
    symbol = "";
    style = "bg:color_yellow fg:color_bg1";
    format = "[ $symbol $branch ]($style)";
  };
  git_commit = {
    disabled = false;
    tag_disabled = false;
    tag_symbol = " 󰓼 ";
    style = "bg:color_yellow fg:color_bg1";
    format = "[ $hash$tag ]($style)";
  };
  git_state = {
    disabled = false;
    style = "bold bg:color_yellow fg:color_red";
    format = "[$state $progress_current/$progress_total ]($style)";
  };
  git_status = {
    disabled = false;
    style = "bold bg:color_yellow fg:color_red";
    format = "[$all_status$ahead_behind]($style)";
  };
  rust = {
    disabled = false;
    symbol = "";
    style = "bg:color_brightgreen fg:color_bg1";
    format = "[ $symbol ]($style)";
  };
  golang = {
    disabled = false;
    symbol = "";
    style = "bg:color_brightgreen fg:color_bg1";
    format = "[ $symbol ]($style)";
  };
  python = {
    disabled = false;
    symbol = "";
    style = "bg:color_brightgreen fg:color_bg1";
    format = "[ $symbol $virtualenv ]($style)";
  };
  helm = {
    disabled = false;
    symbol = "";
    style = "bg:color_brightgreen fg:color_bg1";
    format = "[ $symbol ]($style)";
  };
  package = {
    disabled = false;
    symbol = "󰏗";
    style = "bg:color_brightgreen fg:color_bg1";
    format = "[$symbol $version ]($style)";
  };
  kubernetes = {
    disabled = false;
    symbol = "󱃾";
    style = "bg:color_brightorange fg:color_bg1";
    format = "[ $symbol $context:$namespace ]($style)";
    detect_files = [
      "k8s"
      ".k8s"
      ".kube"
    ];
  };
  cmd_duration = {
    disabled = false;
    style = "fg:color_brightblack";
    min_time = 5000;
    format = "[  $duration]($style)";
  };
  line_break = {
    disabled = true;
  };
  character = {
    disabled = false;
    success_symbol = "[](bold fg:color_green)";
    error_symbol = "[ !](bold fg:color_red)";
  };
}
