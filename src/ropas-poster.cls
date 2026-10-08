%% ropas-poster.cls
%% A single-page scientific poster class.
\NeedsTeXFormat{LaTeX2e}[2025-11-01]
\ProvidesExplClass
  {ropas-poster}
  {2026-10-09}
  {0.0.0b0}
  {Single-page ROPAS posters}

% cmap must precede fontenc; it only supports PDF output from pdfTeX.
\ExplSyntaxOn
\sys_if_engine_pdftex:T
  {
  \RequirePackage{cmap}
  }
\ExplSyntaxOff
% SIunits normally claims \square, which is an existing math symbol here.
% Its documented squaren option keeps that symbol and names the unit macro
% \squaren instead; this also applies when SIunits is loaded transitively.
\PassOptionsToPackage{squaren}{SIunits}
\PassOptionsToPackage{squaren}{binary}
% xxcolor uses a PGF utility macro during actual colour changes but does not
% load PGF itself.  Ensure that dependency exists only if xxcolor is requested.
\AddToHook{package/xxcolor/before}{\RequirePackage{pgf}}
% showcharinbox measures \bullet while loading in the preamble; unicode-math
% does not finish installing that alias until the document begins.
\ExplSyntaxOn
\bool_new:N \g_ropas_showchar_bullet_bool
\cs_new:Npn \ropas_showchar_saved_cdot {}
\AddToHook{package/showcharinbox/before}
  {
    \cs_gset_eq:NN \ropas_showchar_saved_cdot \cdot
    \cs_gset:Npn \cdot {\mathbin{\hbox{\textperiodcentered}}}
    \cs_if_exist:NF \smblkcircle
      {
        \bool_gset_true:N \g_ropas_showchar_bullet_bool
        \cs_gset:Npn \smblkcircle {\mathbin{\hbox{\textbullet}}}
      }
  }
\AddToHook{package/showcharinbox/after}
  {
    \cs_gset_eq:NN \cdot \ropas_showchar_saved_cdot
    \bool_if:NT \g_ropas_showchar_bullet_bool
      {\cs_undefine:N \smblkcircle}
  }
% Additional scratch registers used by the recursive layout code.
\tl_new:N \l_ropas_tmpc_tl
\tl_new:N \l_ropas_tmpd_tl
\dim_new:N \l_ropas_tmpc_dim
\dim_new:N \l_ropas_tmpd_dim
\int_new:N \l_ropas_tmpc_int

% --------------------------------------------------------------------------
% Diagnostics
% --------------------------------------------------------------------------

\cs_new_protected:Npn \ropas_class_error:nn #1#2
  { \ClassError { ropas-poster } {#1} {#2} }

\cs_new_protected:Npn \ropas_class_info:n #1
  { \ClassInfo { ropas-poster } {#1} }

% Parse all option pairs before validating any value.  A repeated key is
% replaced by its last occurrence, including colour/color spellings.
\prop_new:N \l_ropas_option_last_prop
\cs_generate_variant:Nn \prop_put:Nnn {NVn,Nxx}
\cs_new_protected:Npn \ropas_option_store:nn #1#2
  {
    \tl_set:Nx \l_tmpa_tl {\tl_trim_spaces:n {#1}}
    \regex_replace_once:nnN {color\Z} {colour} \l_tmpa_tl
    \prop_put:NVn \l_ropas_option_last_prop \l_tmpa_tl {#2}
  }
\cs_new_protected:Npn \ropas_option_store:n #1
  {\ropas_option_store:nn {#1}{}}
\cs_new_protected:Npn \ropas_keys_set_last:nn #1#2
  {
    \tl_if_blank:nF {#2}
      {
        \prop_clear:N \l_ropas_option_last_prop
        \keyval_parse:NNn \ropas_option_store:n \ropas_option_store:nn {#2}
        \prop_map_inline:Nn \l_ropas_option_last_prop
          {\keys_set:nn {#1} {##1={##2}}}
      }
  }

% --------------------------------------------------------------------------
% Global configuration
% --------------------------------------------------------------------------

\dim_new:N \g_ropas_paper_width_dim
\dim_new:N \g_ropas_paper_height_dim
\dim_new:N \g_ropas_header_height_dim
\tl_new:N  \g_ropas_header_background_tl
\tl_new:N  \g_ropas_body_background_tl
\dim_new:N \g_ropas_header_top_dim
\dim_new:N \g_ropas_header_bottom_dim
\dim_new:N \g_ropas_header_leading_dim

\dim_new:N \g_ropas_title_size_dim
\tl_new:N  \g_ropas_title_colour_tl
\tl_new:N  \g_ropas_title_tl
\dim_new:N \g_ropas_subtitle_size_dim
\tl_new:N  \g_ropas_subtitle_colour_tl
\tl_new:N  \g_ropas_subtitle_tl
\dim_new:N \g_ropas_author_size_dim
\tl_new:N  \g_ropas_author_colour_tl
\tl_new:N  \g_ropas_author_tl
\dim_new:N \g_ropas_institute_size_dim
\tl_new:N  \g_ropas_institute_colour_tl
\tl_new:N  \g_ropas_institute_tl

\dim_new:N \g_ropas_body_top_dim
\dim_new:N \g_ropas_body_side_dim
\dim_new:N \g_ropas_body_bottom_dim
\tl_new:N  \g_ropas_cell_bg_colour_tl
\dim_new:N \g_ropas_cell_gap_dim
\dim_new:N \g_ropas_cell_margin_dim
\dim_new:N \g_ropas_cell_corner_radius_dim
\int_new:N \g_ropas_column_num_int
\dim_new:N \g_ropas_column_gap_dim
\dim_new:N \g_ropas_text_leading_dim
\dim_new:N \g_ropas_paragraph_leading_dim
\dim_new:N \g_ropas_paragraph_indent_dim
\dim_new:N \l_ropas_paragraph_indent_dim
\tl_new:N  \g_ropas_align_tl
\dim_new:N \g_ropas_cell_title_size_dim
\tl_new:N  \g_ropas_cell_title_colour_tl
\dim_new:N \g_ropas_section_title_size_dim
\tl_new:N  \g_ropas_section_title_colour_tl
\dim_new:N \g_ropas_text_size_dim
\tl_new:N  \g_ropas_text_colour_tl

% Poster-relative replacements for the standard LaTeX size declarations.
% The active base changes with the component being typeset; the global base
% is the current theme's text size and is used outside such a component.
\dim_new:N \g_ropas_size_base_dim
\dim_new:N \g_ropas_size_baseline_dim
\dim_new:N \l_ropas_size_base_dim
\dim_new:N \l_ropas_size_baseline_dim

\cs_new_protected:Npn \ropas_set_size_base:nn #1#2
  {
    \dim_set:Nn \l_ropas_size_base_dim {#1}
    \dim_set:Nn \l_ropas_size_baseline_dim {#2}
  }

\cs_new_protected:Npn \ropas_reset_default_size_base:
  {
    \dim_gset_eq:NN \g_ropas_size_base_dim \g_ropas_text_size_dim
    \dim_gset:Nn \g_ropas_size_baseline_dim
      { \g_ropas_text_size_dim + \g_ropas_text_leading_dim }
    \dim_gset_eq:NN \l_ropas_size_base_dim \g_ropas_size_base_dim
    \dim_gset_eq:NN \l_ropas_size_baseline_dim
      \g_ropas_size_baseline_dim
  }

\cs_new_protected:Npn \ropas_select_relative_size:n #1
  {
    \fontsize
      { \fp_to_dim:n
          { (#1) * \dim_to_fp:n { \l_ropas_size_base_dim } } }
      { \fp_to_dim:n
          { (#1) * \dim_to_fp:n { \l_ropas_size_baseline_dim } } }
    \selectfont
  }

\dim_new:N \g_ropas_logo_height_dim
\seq_new:N \g_ropas_logos_seq

\prop_new:N \g_ropas_paper_sizes_prop
\prop_gput:Nnn \g_ropas_paper_sizes_prop { A0 }  { 841mm,1189mm }
\prop_gput:Nnn \g_ropas_paper_sizes_prop { A1 }  { 594mm,841mm }
\prop_gput:Nnn \g_ropas_paper_sizes_prop { A2 }  { 420mm,594mm }
\prop_gput:Nnn \g_ropas_paper_sizes_prop { A3 }  { 297mm,420mm }
\prop_gput:Nnn \g_ropas_paper_sizes_prop { A4 }  { 210mm,297mm }
\prop_gput:Nnn \g_ropas_paper_sizes_prop { A5 }  { 148mm,210mm }
\prop_gput:Nnn \g_ropas_paper_sizes_prop { A6 }  { 105mm,148mm }
\prop_gput:Nnn \g_ropas_paper_sizes_prop { A7 }  { 74mm,105mm }
\prop_gput:Nnn \g_ropas_paper_sizes_prop { A8 }  { 52mm,74mm }
\prop_gput:Nnn \g_ropas_paper_sizes_prop { A9 }  { 37mm,52mm }
\prop_gput:Nnn \g_ropas_paper_sizes_prop { A10 } { 26mm,37mm }
\prop_gput:Nnn \g_ropas_paper_sizes_prop { 4A0 } { 1682mm,2378mm }
\prop_gput:Nnn \g_ropas_paper_sizes_prop { 2A0 } { 1189mm,1682mm }
\prop_gput:Nnn \g_ropas_paper_sizes_prop { B0 }  { 1000mm,1414mm }
\prop_gput:Nnn \g_ropas_paper_sizes_prop { B1 }  { 707mm,1000mm }
\prop_gput:Nnn \g_ropas_paper_sizes_prop { B2 }  { 500mm,707mm }
\prop_gput:Nnn \g_ropas_paper_sizes_prop { B3 }  { 353mm,500mm }
\prop_gput:Nnn \g_ropas_paper_sizes_prop { B4 }  { 250mm,353mm }
\prop_gput:Nnn \g_ropas_paper_sizes_prop { B5 }  { 176mm,250mm }
\prop_gput:Nnn \g_ropas_paper_sizes_prop { B6 }  { 125mm,176mm }
\prop_gput:Nnn \g_ropas_paper_sizes_prop { B7 }  { 88mm,125mm }
\prop_gput:Nnn \g_ropas_paper_sizes_prop { B8 }  { 62mm,88mm }
\prop_gput:Nnn \g_ropas_paper_sizes_prop { B9 }  { 44mm,62mm }
\prop_gput:Nnn \g_ropas_paper_sizes_prop { B10 } { 31mm,44mm }

\cs_new_protected:Npn \ropas_set_positive_dim:Nnn #1#2#3
  {
    \dim_set:Nn \l_tmpa_dim {#3}
    \dim_compare:nNnTF { \l_tmpa_dim } > { 0pt }
      { \dim_gset_eq:NN #1 \l_tmpa_dim }
      {
        \ropas_class_error:nn
          { #2~must~be~a~positive~LaTeX~length }
          { Supply~a~length~strictly~greater~than~zero. }
      }
  }

\cs_new_protected:Npn \ropas_set_nonnegative_dim:Nnn #1#2#3
  {
    \dim_set:Nn \l_tmpa_dim {#3}
    \dim_compare:nNnTF { \l_tmpa_dim } < { 0pt }
      {
        \ropas_class_error:nn
          { #2~must~be~a~non-negative~LaTeX~length }
          { Supply~a~length~greater~than~or~equal~to~zero. }
      }
      { \dim_gset_eq:NN #1 \l_tmpa_dim }
  }

\cs_new_protected:Npn \ropas_set_positive_int:Nnn #1#2#3
  {
    \regex_match:nnTF { \A \s* [0-9]+ \s* \Z } {#3}
      {
        \int_compare:nNnTF {#3} > { 0 }
          { \int_gset:Nn #1 {#3} }
          {
            \ropas_class_error:nn { #2~must~be~positive }
              { Supply~an~integer~strictly~greater~than~zero. }
          }
      }
      {
        \ropas_class_error:nn { #2~must~be~an~integer }
          { Supply~a~positive~integer. }
      }
  }

\cs_new_protected:Npn \ropas_set_named_paper:nn #1#2
  {
    \tl_set:Nx \l_tmpb_tl { \tl_trim_spaces:e {#1} }
    \tl_set:Nx \l_ropas_tmpc_tl { \tl_trim_spaces:e {#2} }
    \prop_get:NVNTF \g_ropas_paper_sizes_prop \l_tmpb_tl \l_tmpa_tl
      {
        \seq_set_split:NnV \l_tmpa_seq { , } \l_tmpa_tl
        \str_case:VnF \l_ropas_tmpc_tl
          {
            { portrait }
              {
                \dim_gset:Nn \g_ropas_paper_width_dim
                  { \seq_item:Nn \l_tmpa_seq {1} }
                \dim_gset:Nn \g_ropas_paper_height_dim
                  { \seq_item:Nn \l_tmpa_seq {2} }
              }
            { landscape }
              {
                \dim_gset:Nn \g_ropas_paper_width_dim
                  { \seq_item:Nn \l_tmpa_seq {2} }
                \dim_gset:Nn \g_ropas_paper_height_dim
                  { \seq_item:Nn \l_tmpa_seq {1} }
              }
          }
          {
            \ropas_class_error:nn { Unknown~paper~orientation~'\l_ropas_tmpc_tl' }
              { Use~'portrait'~or~'landscape'. }
          }
      }
      {
        \ropas_class_error:nn { Unknown~paper~size~'\l_tmpb_tl' }
          { Use~one~of~the~paper~names~documented~by~ropas-poster. }
      }
  }

\cs_new_protected:Npn \ropas_set_custom_paper:nn #1#2
  {
    \ropas_set_positive_dim:Nnn \g_ropas_paper_width_dim
      { Paper~width } {#1}
    \ropas_set_positive_dim:Nnn \g_ropas_paper_height_dim
      { Paper~height } {#2}
  }

\cs_new_protected:Npn \ropas_parse_paper:n #1
  {
    \seq_set_split:Nnn \l_tmpa_seq { , } {#1}
    \int_case:nnF { \seq_count:N \l_tmpa_seq }
      {
        { 1 }
          {
            \ropas_set_named_paper:nn
              { \tl_trim_spaces:e { \seq_item:Nn \l_tmpa_seq {1} } }
              { portrait }
          }
        { 2 }
          {
            \tl_set:Nx \l_tmpa_tl
              { \tl_trim_spaces:e { \seq_item:Nn \l_tmpa_seq {1} } }
            \tl_set:Nx \l_tmpb_tl
              { \tl_trim_spaces:e { \seq_item:Nn \l_tmpa_seq {2} } }
            \str_if_eq:VnTF \l_tmpb_tl { portrait }
              { \ropas_set_named_paper:VV \l_tmpa_tl \l_tmpb_tl }
              {
                \str_if_eq:VnTF \l_tmpb_tl { landscape }
                  { \ropas_set_named_paper:VV \l_tmpa_tl \l_tmpb_tl }
                  { \ropas_set_custom_paper:VV \l_tmpa_tl \l_tmpb_tl }
              }
          }
      }
      {
        \ropas_class_error:nn { Invalid~paper~specification~'#1' }
          { Use~a~paper~name,~a~name~and~orientation,~or~two~lengths. }
      }
  }
\cs_generate_variant:Nn \ropas_set_named_paper:nn { VV }
\cs_generate_variant:Nn \ropas_set_custom_paper:nn { VV }

% Class options are saved until all class support code is available.
\tl_new:N \g_ropas_class_paper_tl
\tl_new:N \g_ropas_class_theme_tl
\tl_gset:Nn \g_ropas_class_paper_tl { A0 }
\tl_gset:Nn \g_ropas_class_theme_tl { default }

\keys_define:nn { ropas-poster / class }
  {
    paper .tl_gset:N = \g_ropas_class_paper_tl,
    theme .tl_gset:N = \g_ropas_class_theme_tl,
    unknown .code:n =
      {
        \ropas_class_error:nn { Unknown~class~option~'\l_keys_key_str' }
          { The~class~accepts~only~the~paper~and~theme~options. }
      }
  }
\ProcessKeyOptions [ ropas-poster / class ]

\ExplSyntaxOff

% Standalone document class: provide only the LaTeX-level structures used by
% the poster.  No standard document class is loaded.
\ExplSyntaxOn
\cs_set_protected:Npn \normalsize
  { \@setfontsize\normalsize{10pt}{12pt} }
% microtype reads these standard size declarations while loading.  Their
% poster-relative definitions replace them once the theme is initialized.
\cs_set_protected:Npn \footnotesize
  { \@setfontsize\footnotesize{8pt}{9.6pt} }
\cs_set_protected:Npn \small
  { \@setfontsize\small{9pt}{10.8pt} }
\cs_set_protected:Npn \large
  { \@setfontsize\large{10.95pt}{13.14pt} }
\normalsize
\clist_map_inline:nn
  {
    tiny,scriptsize,footnotesize,small,large,Large,LARGE,huge,Huge,
    title,author,maketitle,part,section,subsection,subsubsection,
    paragraph,subparagraph,appendix,tableofcontents,listoffigures,
    listoftables,newblock,subitem,subsubitem,indexspace,
    rm,sf,tt,bf,it,sl,sc,cal,mit,
    theequation,figurename,tablename,
    theenumi,theenumii,theenumiii,theenumiv,
    labelenumi,labelenumii,labelenumiii,labelenumiv,
    labelitemi,labelitemii,labelitemiii,labelitemiv,labelitemfont,
    thepart,thesection,thesubsection,thesubsubsection,
    theparagraph,thesubparagraph,descriptionlabel,
    contentsname,listfigurename,listtablename,refname,indexname,
    partname,appendixname,abstractname
  }
  { \cs_if_exist:cF {#1} { \cs_new:cpn {#1} {} } }
\clist_map_inline:nn
  {titlepage,abstract,description,verse,quotation,quote,
   thebibliography,theindex,figure,figure*,table,table*}
  {
    \cs_if_exist:cF {#1} { \cs_new:cpn {#1} {} }
    \cs_if_exist:cF {end#1} { \cs_new:cpn {end#1} {} }
  }
\ExplSyntaxOff
\newcounter{figure}
\newcounter{table}
\providecommand\thepage{\arabic{page}}
\setlength{\paperwidth}{841mm}
\setlength{\paperheight}{1189mm}
\ExplSyntaxOn
\cs_if_exist:cF {c@enumi} {\newcounter{enumi}}
\cs_if_exist:cF {c@enumii} {\newcounter{enumii}[enumi]}
\cs_if_exist:cF {c@enumiii} {\newcounter{enumiii}[enumii]}
\cs_if_exist:cF {c@enumiv} {\newcounter{enumiv}[enumiii]}
\cs_if_exist:cF {c@equation} {\newcounter{equation}}
\ExplSyntaxOff
\makeatletter
\def\fps@figure{tb}\def\ftype@figure{1}\def\ext@figure{lof}
\def\fnum@figure{\figurename\nobreakspace\thefigure}
\def\fps@table{tb}\def\ftype@table{2}\def\ext@table{lot}
\def\fnum@table{\tablename\nobreakspace\thetable}
% Keep the standard footnote formatter hook available to packages even though
% poster blocks collect and render their own footnotes.
\def\@makefntext#1{\parindent 1em\noindent
  \hb@xt@1.8em{\hss\@makefnmark}#1}

\RequirePackage{etoolbox}
\RequirePackage{graphicx}
\RequirePackage[prologue]{xcolor}
\RequirePackage{geometry}
\RequirePackage{caption3}
\let\@makecaption\@makecaption@standard
\RequirePackage{caption}
% Load the AMS symbol layer before newtxmath.  This is the supported load
% order and lets users request it again without a duplicate \Bbbk error.
\RequirePackage{amsmath}
\RequirePackage{amssymb}

% Match the font setup in the repository's reference acmart.cls.
\ExplSyntaxOn
\sys_if_engine_pdftex:TF
 {
  \RequirePackage[T1]{fontenc}
  \RequirePackage[tt=false,type1=true]{libertine}
  \RequirePackage[varqu]{zi4}
  \RequirePackage[libertine]{newtxmath}
 }
 {
  \bool_lazy_or:nnTF
    { \sys_if_engine_xetex_p: }
    { \sys_if_engine_luatex_p: }
   {
    \RequirePackage{unicode-math}
    \setmathfont[Scale=MatchUppercase]{LibertinusMath-Regular.otf}
    \setmathfont{latinmodern-math.otf}[range={cal}]
    \RequirePackage[tt=false]{libertine}
    \setmonofont[StylisticSet=3]{inconsolata}
   }
   {
    \ClassError{ropas-poster}
      {Unsupported~TeX~engine}
      {Use~pdfLaTeX,~XeLaTeX,~or~LuaLaTeX.}
   }
 }

\DeclareCaptionFont{ropas-cell}
  {
    \sffamily
    \small
    \color{\l_ropas_text_colour_tl}
  }

% newtxmath defines \openbox, while amsthm expects to create that command.
% Remove just that definition if and when a document asks for amsthm; avoiding
% an unconditional amsthm load also keeps alternative theorem packages usable.
\AddToHook { package/amsthm/before }
  { \cs_undefine:N \openbox }
\RequirePackage{amsthm}
\RequirePackage{booktabs}
\RequirePackage{comment}
% Footnotes are collected and typeset by the poster, not by LaTeX's ordinary
% \@footnotetext formatter, so microtype's formatter patch cannot apply.
\RequirePackage[nopatch=footnote]{microtype}
\RequirePackage[bookmarksnumbered,unicode]{hyperref}
% Poster floats have no ordinary float-top hyperlink anchor.
\captionsetup{hypcap=false}

\seq_new:N \g_ropas_theorem_size_stack_seq
\dim_new:N \g_ropas_theorem_current_size_dim
\dim_gset:Nn \g_ropas_theorem_current_size_dim {45bp}

\cs_new_protected:Npn \ropas_set_theorem_styles:n #1
  {
    \newtheoremstyle{acmplain}
      {\fp_to_dim:n{0.6*\dim_to_fp:n{#1}}
        plus \fp_to_dim:n{0.24*\dim_to_fp:n{#1}}
        minus \fp_to_dim:n{0.24*\dim_to_fp:n{#1}}}
      {\fp_to_dim:n{0.6*\dim_to_fp:n{#1}}
        plus \fp_to_dim:n{0.24*\dim_to_fp:n{#1}}
        minus \fp_to_dim:n{0.24*\dim_to_fp:n{#1}}}
      {\itshape}{\l_ropas_paragraph_indent_dim}{\scshape}{.}
      {\fp_to_dim:n{0.5*\dim_to_fp:n{#1}}}
      {\thmname{##1}\thmnumber{ ##2}\thmnote{ (##3)}}
    \newtheoremstyle{acmdefinition}
      {\fp_to_dim:n{0.6*\dim_to_fp:n{#1}}
        plus \fp_to_dim:n{0.24*\dim_to_fp:n{#1}}
        minus \fp_to_dim:n{0.24*\dim_to_fp:n{#1}}}
      {\fp_to_dim:n{0.6*\dim_to_fp:n{#1}}
        plus \fp_to_dim:n{0.24*\dim_to_fp:n{#1}}
        minus \fp_to_dim:n{0.24*\dim_to_fp:n{#1}}}
      {\normalfont}{\l_ropas_paragraph_indent_dim}{\itshape}{.}
      {\fp_to_dim:n{0.5*\dim_to_fp:n{#1}}}
      {\thmname{##1}\thmnumber{ ##2}\thmnote{ (##3)}}
  }

\cs_new_protected:Npn \ropas_theorem_style_enter:n #1
  {
    \seq_gput_right:Nx \g_ropas_theorem_size_stack_seq
      {\dim_use:N \g_ropas_theorem_current_size_dim}
    \dim_gset:Nn \g_ropas_theorem_current_size_dim {#1}
    \ropas_set_theorem_styles:n {#1}
  }

\cs_new_protected:Npn \ropas_theorem_style_leave:
  {
    \seq_gpop_right:NN \g_ropas_theorem_size_stack_seq \l_tmpa_tl
    \dim_gset:Nn \g_ropas_theorem_current_size_dim {\l_tmpa_tl}
    \ropas_set_theorem_styles:n {\l_tmpa_tl}
  }

\ropas_set_theorem_styles:n {45bp}
\theoremstyle{acmplain}

\prop_new:N \g_ropas_footnote_data_prop
\int_new:N \g_ropas_footnote_id_int
\tl_new:N \g_ropas_current_footnote_owner_tl
\seq_new:c {g_ropas_child_document_notes_seq}
\box_new:c {g_ropas_child_document_footnote_box}
\cs_generate_variant:Nn \seq_gput_right:Nn {cx}
\cs_new_eq:NN \ropas_kernel_footnotemark: \@footnotemark
\cs_set_protected:Npn \@footnotemark
  {
    \prop_gput:Nxx \g_ropas_footnote_data_prop
      {owner/\@thefnmark} {\g_ropas_current_footnote_owner_tl}
    \ropas_kernel_footnotemark:
  }
\cs_set_protected:Npn \@footnotetext #1
  {
    \prop_get:NxNTF \g_ropas_footnote_data_prop
      {owner/\@thefnmark} \l_tmpa_tl
      { }
      {\tl_set_eq:NN \l_tmpa_tl \g_ropas_current_footnote_owner_tl}
    \int_gincr:N \g_ropas_footnote_id_int
    \prop_gput:Nxx \g_ropas_footnote_data_prop
      {note/\int_use:N \g_ropas_footnote_id_int/mark}
      {\@thefnmark}
    \prop_gput:Nxn \g_ropas_footnote_data_prop
      {note/\int_use:N \g_ropas_footnote_id_int/body} {#1}
    \seq_gput_right:cx
      {g_ropas_child_\l_tmpa_tl _notes_seq}
      {\int_use:N \g_ropas_footnote_id_int}
  }

\cs_new_protected:Npn \ropas_build_footnotes:nn #1#2
  {
    \vbox_gset:cn {g_ropas_child_#1_footnote_box}
      {
        \hsize=#2\linewidth=\hsize\parindent=0pt\parskip=0pt
        \everypar{}
        \sffamily
        \fontsize
          {\fp_to_dim:n{0.8*\dim_to_fp:n{\l_ropas_text_size_dim}}}
          {\fp_to_dim:n{0.8*\dim_to_fp:n
              {\l_ropas_text_size_dim+\l_ropas_text_leading_dim}}}
        \selectfont\color{\l_ropas_text_colour_tl}
        \exp_args:Nc \seq_map_inline:Nn
          {g_ropas_child_#1_notes_seq}
          {
            \prop_get:NxN \g_ropas_footnote_data_prop
              {note/##1/mark} \l_tmpa_tl
            \prop_get:NxN \g_ropas_footnote_data_prop
              {note/##1/body} \l_tmpb_tl
            \noindent\textsuperscript{\l_tmpa_tl}\,\tl_use:N \l_tmpb_tl\par
          }
      }
  }
\newtheorem{theorem}{Theorem}
\newtheorem{conjecture}[theorem]{Conjecture}
\newtheorem{proposition}[theorem]{Proposition}
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{corollary}[theorem]{Corollary}
\theoremstyle{acmdefinition}
\newtheorem{example}[theorem]{Example}
\newtheorem{definition}[theorem]{Definition}
\theoremstyle{acmplain}

% Libertinus Math does not contain a small set of symbols which the
% PDFLaTeX branch of the reference acmart.cls obtains from newtxmath.
% Keep unicode-math for every other symbol, but take precisely those missing
% glyphs from the same legacy newtx fonts and slots as the PDFLaTeX branch.
\bool_new:N \g_ropas_unicode_engine_bool
\sys_if_engine_xetex:T
  { \bool_gset_true:N \g_ropas_unicode_engine_bool }
\sys_if_engine_luatex:T
  { \bool_gset_true:N \g_ropas_unicode_engine_bool }

\cs_new_protected:Npn \ropas_newtx_symbol:nnnn #1#2#3#4
  {
    \exp_args:Nc \DeclareMathSymbol { ropas_newtx_#1_mathchar }
      {#2} {#3} {#4}
    \cs_gset_eq:cc {#1} { ropas_newtx_#1_mathchar }
  }

\cs_new_protected:Npn \ropas_newtx_delimiter:nnnnnn #1#2#3#4#5#6
  {
    \exp_args:Nc \DeclareMathDelimiter { ropas_newtx_#1_mathchar }
      {#2} {#3} {#4} {#5} {#6}
    \cs_gset_eq:cc {#1} { ropas_newtx_#1_mathchar }
  }

\cs_new_protected:Npn \ropas_restore_unicode_newtx_fallbacks:
  {
    \clist_map_inline:nn
      {
        Angstrom,laplac,precnapprox,succnapprox,lnapprox,gnapprox,
        diagup,diagdown,subsetneqq,supsetneqq,divideontimes,Finv,Game,
        precapprox,succapprox,gtrapprox,multimap,lessapprox,eqslantless,
        eqslantgtr,blacktriangledown,vartriangle,blacktriangle,
        triangledown,lesseqqgtr,gtreqqless,veebar,barwedge,
        doublebarwedge,Subset,Supset,Cup,Cap,leftthreetimes,
        rightthreetimes,subseteqq,supseteqq,bumpeq,Bumpeq,pitchfork,
        intercal,checkmark,maltese,multimapinv,Coloneq,Join,boxast,
        boxbslash,boxbar,lbag,rbag
      }
      { \cs_gset_eq:cc {##1} { ropas_newtx_##1_mathchar } }
    \cs_gset_protected:Npn \bigtimes
      { \DOTSI \ropas_bigtimes_op \slimits@ }
    \cs_gset_protected:Npn \sumint
      { \DOTSI \ropas_sumint_op \ilimits@ }
    \cs_gset_protected:Npn \fint
      { \DOTSI \ropas_fint_op \ilimits@ }
    \cs_gset_protected:Npn \sqint
      { \DOTSI \ropas_sqint_op \ilimits@ }
  }

\cs_new_protected:Npn \ropas_install_unicode_newtx_fallbacks:
  {
    \DeclareFontEncoding { LMS } { } { }
    \DeclareFontSubstitution { LMS } { ropasntxsy } { m } { n }
    \DeclareFontFamily { U } { ropasnxlmia } { \skewchar \font = 127 }
    \DeclareFontShape { U } { ropasnxlmia } { m } { it }
      { <-> nxlmia } { }
    \DeclareFontFamily { LMS } { ropasntxsy }
      { \providecommand \setSYdimens { } \setSYdimens \skewchar \font = 120 }
    \DeclareFontShape { LMS } { ropasntxsy } { m } { n }
      { <-6.3> ntxsy5 <6.3-8.6> ntxsy7 <8.6-> ntxsy } { }
    \DeclareFontFamily { U } { ropasntxsym } { }
    \DeclareFontShape { U } { ropasntxsym } { m } { n }
      { <-> ntxsym } { }
    \DeclareFontFamily { U } { ropasntxsyc } { }
    \DeclareFontShape { U } { ropasntxsyc } { m } { n }
      { <-> ntxsyc } { }
    \DeclareFontFamily { U } { ropasntxexa } { }
    \DeclareFontShape { U } { ropasntxexa } { m } { n }
      { <-> ntxexa } { }
    \DeclareSymbolFont { ropaslettersA } { U } { ropasnxlmia } { m } { it }
    \DeclareSymbolFont { ropassymbols } { LMS } { ropasntxsy } { m } { n }
    \DeclareSymbolFont { ropasAMSm } { U } { ropasntxsym } { m } { n }
    \DeclareSymbolFont { ropassymbolsC } { U } { ropasntxsyc } { m } { n }
    \DeclareSymbolFont { ropaslargeTXA } { U } { ropasntxexa } { m } { n }

    \ropas_newtx_symbol:nnnn { Angstrom } { \mathord } { ropaslettersA } { 95 }
    \ropas_newtx_symbol:nnnn { laplac } { \mathord } { ropassymbols } { 218 }

    \ropas_newtx_symbol:nnnn { precnapprox } { \mathrel } { ropasAMSm } { 24 }
    \ropas_newtx_symbol:nnnn { succnapprox } { \mathrel } { ropasAMSm } { 25 }
    \ropas_newtx_symbol:nnnn { lnapprox } { \mathrel } { ropasAMSm } { 26 }
    \ropas_newtx_symbol:nnnn { gnapprox } { \mathrel } { ropasAMSm } { 27 }
    \ropas_newtx_symbol:nnnn { diagup } { \mathord } { ropasAMSm } { 30 }
    \ropas_newtx_symbol:nnnn { diagdown } { \mathord } { ropasAMSm } { 31 }
    \ropas_newtx_symbol:nnnn { subsetneqq } { \mathrel } { ropasAMSm } { 36 }
    \ropas_newtx_symbol:nnnn { supsetneqq } { \mathrel } { ropasAMSm } { 37 }
    \ropas_newtx_symbol:nnnn { divideontimes } { \mathbin } { ropasAMSm } { 62 }
    \ropas_newtx_symbol:nnnn { Finv } { \mathord } { ropasAMSm } { 96 }
    \ropas_newtx_symbol:nnnn { Game } { \mathord } { ropasAMSm } { 97 }
    \ropas_newtx_symbol:nnnn { precapprox } { \mathrel } { ropasAMSm } { 118 }
    \ropas_newtx_symbol:nnnn { succapprox } { \mathrel } { ropasAMSm } { 119 }
    \ropas_newtx_symbol:nnnn { gtrapprox } { \mathrel } { ropasAMSm } { 167 }
    \ropas_newtx_symbol:nnnn { multimap } { \mathrel } { ropasAMSm } { 168 }
    \ropas_newtx_symbol:nnnn { lessapprox } { \mathrel } { ropasAMSm } { 175 }
    \ropas_newtx_symbol:nnnn { eqslantless } { \mathrel } { ropasAMSm } { 176 }
    \ropas_newtx_symbol:nnnn { eqslantgtr } { \mathrel } { ropasAMSm } { 177 }
    \ropas_newtx_symbol:nnnn { blacktriangledown } { \mathord } { ropasAMSm } { 200 }
    \ropas_newtx_symbol:nnnn { vartriangle } { \mathrel } { ropasAMSm } { 205 }
    \ropas_newtx_symbol:nnnn { blacktriangle } { \mathord } { ropasAMSm } { 206 }
    \ropas_newtx_symbol:nnnn { triangledown } { \mathord } { ropasAMSm } { 207 }
    \ropas_newtx_symbol:nnnn { lesseqqgtr } { \mathrel } { ropasAMSm } { 211 }
    \ropas_newtx_symbol:nnnn { gtreqqless } { \mathrel } { ropasAMSm } { 212 }
    \ropas_newtx_symbol:nnnn { veebar } { \mathbin } { ropasAMSm } { 217 }
    \ropas_newtx_symbol:nnnn { barwedge } { \mathbin } { ropasAMSm } { 218 }
    \ropas_newtx_symbol:nnnn { doublebarwedge } { \mathbin } { ropasAMSm } { 219 }
    \ropas_newtx_symbol:nnnn { Subset } { \mathrel } { ropasAMSm } { 226 }
    \ropas_newtx_symbol:nnnn { Supset } { \mathrel } { ropasAMSm } { 227 }
    \ropas_newtx_symbol:nnnn { Cup } { \mathbin } { ropasAMSm } { 228 }
    \ropas_newtx_symbol:nnnn { Cap } { \mathbin } { ropasAMSm } { 229 }
    \ropas_newtx_symbol:nnnn { leftthreetimes } { \mathbin } { ropasAMSm } { 232 }
    \ropas_newtx_symbol:nnnn { rightthreetimes } { \mathbin } { ropasAMSm } { 233 }
    \ropas_newtx_symbol:nnnn { subseteqq } { \mathrel } { ropasAMSm } { 234 }
    \ropas_newtx_symbol:nnnn { supseteqq } { \mathrel } { ropasAMSm } { 235 }
    \ropas_newtx_symbol:nnnn { bumpeq } { \mathrel } { ropasAMSm } { 236 }
    \ropas_newtx_symbol:nnnn { Bumpeq } { \mathrel } { ropasAMSm } { 237 }
    \ropas_newtx_symbol:nnnn { pitchfork } { \mathrel } { ropasAMSm } { 244 }
    \ropas_newtx_symbol:nnnn { intercal } { \mathbin } { ropasAMSm } { 252 }
    \ropas_newtx_symbol:nnnn { checkmark } { \mathord } { ropasAMSm } { "D8 }
    \ropas_newtx_symbol:nnnn { maltese } { \mathord } { ropasAMSm } { "FA }

    \ropas_newtx_symbol:nnnn { multimapinv } { \mathrel } { ropassymbolsC } { 18 }
    \ropas_newtx_symbol:nnnn { Coloneq } { \mathrel } { ropassymbolsC } { 70 }
    \ropas_newtx_symbol:nnnn { Join } { \mathrel } { ropassymbolsC } { 90 }
    \ropas_newtx_symbol:nnnn { boxast } { \mathbin } { ropassymbolsC } { 105 }
    \ropas_newtx_symbol:nnnn { boxbslash } { \mathbin } { ropassymbolsC } { 106 }
    \ropas_newtx_symbol:nnnn { boxbar } { \mathbin } { ropassymbolsC } { 107 }
    \ropas_newtx_delimiter:nnnnnn { lbag } { \mathopen }
      { ropassymbolsC } { 78 } { ropaslargeTXA } { 48 }
    \ropas_newtx_delimiter:nnnnnn { rbag } { \mathclose }
      { ropassymbolsC } { 79 } { ropaslargeTXA } { 49 }

    \ropas_newtx_symbol:nnnn { ropas_bigtimes_op } { \mathop }
      { ropaslargeTXA } { "3E }
    \ropas_newtx_symbol:nnnn { ropas_sumint_op } { \mathop }
      { ropaslargeTXA } { "46 }
    \ropas_newtx_symbol:nnnn { ropas_fint_op } { \mathop }
      { ropaslargeTXA } { "4A }
    \ropas_newtx_symbol:nnnn { ropas_sqint_op } { \mathop }
      { ropaslargeTXA } { "4C }
    \ropas_restore_unicode_newtx_fallbacks:
  }

\bool_if:NT \g_ropas_unicode_engine_bool
  {
    \ropas_install_unicode_newtx_fallbacks:
    \AddToHook { begindocument/end }
      { \ropas_restore_unicode_newtx_fallbacks: }
  }

\definecolor{SNUBlue}{HTML}{0F0F70}
\definecolor[named]{SNUBeige}{cmyk}{0.13,0.1,0.25,0}
\definecolor[named]{SNUGray}{cmyk}{0,0,0,0.6}
\definecolor[named]{ACMBlue}{cmyk}{1,0.1,0,0.1}
\definecolor[named]{ACMYellow}{cmyk}{0,0.16,1,0}
\definecolor[named]{ACMOrange}{cmyk}{0,0.42,1,0.01}
\definecolor[named]{ACMRed}{cmyk}{0,0.9,0.86,0}
\definecolor[named]{ACMLightBlue}{cmyk}{0.49,0.01,0,0}
\definecolor[named]{ACMGreen}{cmyk}{0.2,0,1,0.19}
\definecolor[named]{ACMPurple}{cmyk}{0.55,1,0,0.15}
\definecolor[named]{ACMDarkBlue}{cmyk}{1,0.58,0,0.21}
\definecolor{theme-default-bg}{HTML}{194598}
\definecolor{theme-default-text}{HTML}{515151}

\cs_new_protected:Npn \ropas_validate_colour:n #1
  {
    \cs_if_exist:cF {\c_backslash_str color@#1}
      { \ropas_class_error:nn { Undefined~colour~'#1' }
          { Define~the~colour~with~xcolor~before~document~begins. } }
  }

\cs_new_protected:Npn \ropas_validate_background:Nn #1#2
  {
    \exp_args:NV \cs_if_exist:NF #1
      { \ropas_class_error:nn { Undefined~#2~background~command }
          { Define~the~background~command~before~document~begins. } }
  }

\cs_new_protected:Npn \ropas_validate_document_settings:
  {
    \clist_map_inline:nn
      {g_ropas_title_colour_tl,g_ropas_subtitle_colour_tl,
       g_ropas_author_colour_tl,g_ropas_institute_colour_tl,
       g_ropas_cell_bg_colour_tl,g_ropas_cell_title_colour_tl,
       g_ropas_section_title_colour_tl,g_ropas_text_colour_tl}
      {
        \exp_args:Nv \ropas_validate_colour:n {##1}
      }
    \ropas_validate_background:Nn
      \g_ropas_header_background_tl {header}
    \ropas_validate_background:Nn
      \g_ropas_body_background_tl {body}
    \prop_map_inline:Nn \g_ropas_theme_values_prop
      {
        \regex_match:nnT {-colour\Z} {##1}
          {\ropas_validate_colour:n {##2}}
        \regex_match:nnT {-background\Z} {##1}
          {
            \tl_set:Nn \l_tmpa_tl {##2}
            \ropas_validate_background:Nn \l_tmpa_tl {theme}
          }
      }
  }

\cs_new_protected:cpn { poster@theme@default@headerBackground } #1#2
  { \put(0pt,-#2){\color{SNUBlue}\rule{#1}{#2}} }

\cs_new_protected:cpn { poster@theme@default@bodyBackground } #1#2
  {
    \put(0pt,-#2)
      { \color{theme-default-bg}\rule{#1}{45bp} }
    \put(0pt,-#2)
      { \makebox(0pt,0pt)[lb]
          { \includegraphics{ropas-poster/default-bg-0.png} } }
    \put(#1,-#2)
      { \makebox(0pt,0pt)[rb]
          { \includegraphics{ropas-poster/default-bg-1.png} } }
  }

% Theme definitions are validated into a temporary property list and committed
% only after every required item is present and valid.  Repeated keys replace
% their earlier values.  Theme names map to numeric ids so arbitrary non-blank
% names cannot collide with stored keys.
\prop_new:N \g_ropas_themes_prop
\prop_new:N \g_ropas_theme_values_prop
\int_new:N \g_ropas_theme_id_int
\prop_new:N \l_ropas_theme_values_prop
\seq_new:N \l_ropas_theme_missing_seq
\bool_new:N \l_ropas_theme_valid_bool
\tl_new:N \l_ropas_theme_name_tl
\tl_new:N \l_ropas_theme_id_tl

\seq_const_from_clist:Nn \c_ropas_theme_required_seq
  {
    paper-margin-side,header-background,
    header-margin-top,header-margin-bottom,header-leading,
    title-size,title-colour,subtitle-size,subtitle-colour,
    author-size,author-colour,institute-size,institute-colour,
    body-background,body-margin-top,body-margin-bottom,logo-height,
    block-colour,block-sep,block-margin,block-corner-radius,
    block-align,block-column-count,block-column-sep,block-leading,
    block-paragraph-sep,block-paragraph-indent,
    blocktitle-size,blocktitle-colour,
    sectiontitle-size,sectiontitle-colour,text-size,text-colour
  }

\cs_new_protected:Npn \ropas_theme_store_tokens:nn #1#2
  { \prop_put:Nnn \l_ropas_theme_values_prop {#1} {#2} }

\cs_new_protected:Npn \ropas_theme_store_nonblank:nn #1#2
  {
    \tl_if_blank:nTF {#2}
      {
        \bool_set_false:N \l_ropas_theme_valid_bool
        \ropas_class_error:nn { Theme~item~'#1'~must~not~be~blank }
          { Supply~a~non-blank~value. }
      }
      { \prop_put:Nnn \l_ropas_theme_values_prop {#1} {#2} }
  }

\cs_new_protected:Npn \ropas_theme_store_colour:nn #1#2
  {
    \ropas_theme_store_nonblank:nn {#1}{#2}
  }

\cs_new_protected:Npn \ropas_theme_store_positive_dim:nn #1#2
  {
    \dim_set:Nn \l_tmpa_dim {#2}
    \dim_compare:nNnTF { \l_tmpa_dim } > {0pt}
      { \prop_put:Nnx \l_ropas_theme_values_prop {#1}
          { \dim_use:N \l_tmpa_dim } }
      {
        \bool_set_false:N \l_ropas_theme_valid_bool
        \ropas_class_error:nn { Theme~item~'#1'~must~be~a~positive~length }
          { Supply~a~LaTeX~length~strictly~greater~than~zero. }
      }
  }

\cs_new_protected:Npn \ropas_theme_store_nonnegative_dim:nn #1#2
  {
    \dim_set:Nn \l_tmpa_dim {#2}
    \dim_compare:nNnTF { \l_tmpa_dim } < {0pt}
      {
        \bool_set_false:N \l_ropas_theme_valid_bool
        \ropas_class_error:nn
          { Theme~item~'#1'~must~be~a~non-negative~length }
          { Supply~a~LaTeX~length~greater~than~or~equal~to~zero. }
      }
      { \prop_put:Nnx \l_ropas_theme_values_prop {#1}
          { \dim_use:N \l_tmpa_dim } }
  }

\cs_new_protected:Npn \ropas_theme_store_positive_int:nn #1#2
  {
    \regex_match:nnTF { \A \s* [0-9]+ \s* \Z } {#2}
      {
        \int_compare:nNnTF {#2} > {0}
          { \prop_put:Nnx \l_ropas_theme_values_prop {#1}
              { \int_eval:n {#2} } }
          {
            \bool_set_false:N \l_ropas_theme_valid_bool
            \ropas_class_error:nn
              { Theme~item~'#1'~must~be~a~positive~integer }
              { Supply~an~integer~strictly~greater~than~zero. }
          }
      }
      {
        \bool_set_false:N \l_ropas_theme_valid_bool
        \ropas_class_error:nn { Theme~item~'#1'~must~be~an~integer }
          { Supply~a~positive~integer. }
      }
  }

\keys_define:nn { ropas-poster / theme }
  {
    paper-margin-side .code:n =
      { \ropas_theme_store_nonnegative_dim:nn {paper-margin-side}{#1} },
    header-background .code:n =
      { \ropas_theme_store_nonblank:nn {header-background}{#1} },
    header-margin-top .code:n =
      { \ropas_theme_store_nonnegative_dim:nn {header-margin-top}{#1} },
    header-margin-bottom .code:n =
      { \ropas_theme_store_nonnegative_dim:nn {header-margin-bottom}{#1} },
    header-leading .code:n =
      { \ropas_theme_store_nonnegative_dim:nn {header-leading}{#1} },
    title-size .code:n =
      { \ropas_theme_store_positive_dim:nn {title-size}{#1} },
    title-colour .code:n =
      { \ropas_theme_store_colour:nn {title-colour}{#1} },
    subtitle-size .code:n =
      { \ropas_theme_store_positive_dim:nn {subtitle-size}{#1} },
    subtitle-colour .code:n =
      { \ropas_theme_store_colour:nn {subtitle-colour}{#1} },
    author-size .code:n =
      { \ropas_theme_store_positive_dim:nn {author-size}{#1} },
    author-colour .code:n =
      { \ropas_theme_store_colour:nn {author-colour}{#1} },
    institute-size .code:n =
      { \ropas_theme_store_positive_dim:nn {institute-size}{#1} },
    institute-colour .code:n =
      { \ropas_theme_store_colour:nn {institute-colour}{#1} },
    body-background .code:n =
      { \ropas_theme_store_nonblank:nn {body-background}{#1} },
    body-margin-top .code:n =
      { \ropas_theme_store_nonnegative_dim:nn {body-margin-top}{#1} },
    body-margin-bottom .code:n =
      { \ropas_theme_store_nonnegative_dim:nn {body-margin-bottom}{#1} },
    logo-height .code:n =
      { \ropas_theme_store_positive_dim:nn {logo-height}{#1} },
    block-colour .code:n =
      { \ropas_theme_store_colour:nn {block-colour}{#1} },
    block-sep .code:n =
      { \ropas_theme_store_nonnegative_dim:nn {block-sep}{#1} },
    block-margin .code:n =
      { \ropas_theme_store_nonnegative_dim:nn {block-margin}{#1} },
    block-corner-radius .code:n =
      { \ropas_theme_store_nonnegative_dim:nn {block-corner-radius}{#1} },
    block-align .code:n =
      {
        \str_case:nnF {#1}
          {
            {top}{\ropas_theme_store_tokens:nn {block-align}{top}}
            {centre}{\ropas_theme_store_tokens:nn {block-align}{centre}}
            {center}{\ropas_theme_store_tokens:nn {block-align}{centre}}
            {bottom}{\ropas_theme_store_tokens:nn {block-align}{bottom}}
          }
          { \bool_set_false:N \l_ropas_theme_valid_bool
            \ropas_class_error:nn { Invalid~block-align~'#1' }
              { Use~top,~centre/center,~or~bottom. } }
      },
    block-column-count .code:n =
      { \ropas_theme_store_positive_int:nn {block-column-count}{#1} },
    block-column-sep .code:n =
      { \ropas_theme_store_nonnegative_dim:nn {block-column-sep}{#1} },
    block-leading .code:n =
      { \ropas_theme_store_nonnegative_dim:nn {block-leading}{#1} },
    block-paragraph-sep .code:n =
      { \ropas_theme_store_nonnegative_dim:nn {block-paragraph-sep}{#1} },
    block-paragraph-indent .code:n =
      { \ropas_theme_store_nonnegative_dim:nn {block-paragraph-indent}{#1} },
    blocktitle-size .code:n =
      { \ropas_theme_store_positive_dim:nn {blocktitle-size}{#1} },
    blocktitle-colour .code:n =
      { \ropas_theme_store_colour:nn {blocktitle-colour}{#1} },
    sectiontitle-size .code:n =
      { \ropas_theme_store_positive_dim:nn {sectiontitle-size}{#1} },
    sectiontitle-colour .code:n =
      { \ropas_theme_store_colour:nn {sectiontitle-colour}{#1} },
    text-size .code:n =
      { \ropas_theme_store_positive_dim:nn {text-size}{#1} },
    text-colour .code:n =
      { \ropas_theme_store_colour:nn {text-colour}{#1} },
    unknown .code:n =
      {
        \bool_set_false:N \l_ropas_theme_valid_bool
        \ropas_class_error:nn { Unknown~theme~item~'\l_keys_key_str' }
          { Use~the~documented~posterDefineTheme~item~names. }
      }
  }
\keys_define:nn { ropas-poster / theme }
  {
    title-color .meta:n = {title-colour={#1}},
    subtitle-color .meta:n = {subtitle-colour={#1}},
    author-color .meta:n = {author-colour={#1}},
    institute-color .meta:n = {institute-colour={#1}},
    block-color .meta:n = {block-colour={#1}},
    blocktitle-color .meta:n = {blocktitle-colour={#1}},
    sectiontitle-color .meta:n = {sectiontitle-colour={#1}},
    text-color .meta:n = {text-colour={#1}}
  }

\cs_new_protected:Npn \ropas_theme_hardcoded_defaults:
  {
    \keys_set:nn { ropas-poster / theme }
      {
        paper-margin-side=81bp,
        header-background=\poster@theme@default@headerBackground,
        header-margin-top=45bp,
        header-margin-bottom=45bp,
        header-leading=36bp,
        title-size=108bp,
        title-colour=white,
        subtitle-size=81bp,
        subtitle-colour=white,
        author-size=54bp,
        author-colour=white,
        institute-size=45bp,
        institute-colour=white,
        body-background=\poster@theme@default@bodyBackground,
        body-margin-top=27bp,
        body-margin-bottom=63bp,
        logo-height=90bp,
        block-sep=45bp,
        block-colour=white,
        block-corner-radius=45bp,
        block-margin=45bp,
        block-align=top,
        block-column-count=1,
        block-column-sep=45bp,
        block-leading=9bp,
        block-paragraph-sep=45bp,
        block-paragraph-indent=0bp,
        blocktitle-size=54bp,
        blocktitle-colour=SNUBlue,
        sectiontitle-size=45bp,
        sectiontitle-colour=SNUBlue,
        text-size=45bp,
        text-colour=theme-default-text
      }
  }

\cs_new_protected:Npn \ropas_define_theme:nnn #1#2#3
  {
    \group_begin:
      \bool_set_true:N \l_ropas_theme_valid_bool
      \tl_set:Nx \l_ropas_theme_name_tl { \tl_trim_spaces:n {#1} }
      \regex_match:nVTF { \A [A-Za-z0-9-]+ \Z } \l_ropas_theme_name_tl
        { }
        {
          \bool_set_false:N \l_ropas_theme_valid_bool
          \ropas_class_error:nn { Invalid~theme~name }
            { Use~a~non-empty~name~containing~only~letters,~digits,~and~-~. }
        }
      \prop_if_in:NVT \g_ropas_themes_prop \l_ropas_theme_name_tl
        {
          \bool_set_false:N \l_ropas_theme_valid_bool
          \ropas_class_error:nn
            { Theme~'\l_ropas_theme_name_tl'~is~already~defined }
            { Every~theme~name~must~be~unique. }
        }
      \prop_clear:N \l_ropas_theme_values_prop
      \tl_if_blank:nTF {#2}
        { \ropas_theme_hardcoded_defaults: }
        {
          \prop_get:NnNTF \g_ropas_themes_prop {#2} \l_tmpa_tl
            {
              \seq_map_inline:Nn \c_ropas_theme_required_seq
                {
                  \prop_get:NxN \g_ropas_theme_values_prop
                    { theme/\l_tmpa_tl/##1 } \l_tmpb_tl
                  \prop_put:NnV \l_ropas_theme_values_prop {##1} \l_tmpb_tl
                }
            }
            {
              \bool_set_false:N \l_ropas_theme_valid_bool
              \ropas_class_error:nn { Unknown~base~theme~'#2' }
                { Define~the~base~theme~first. }
            }
        }
      \ropas_keys_set_last:nn { ropas-poster / theme } {#3}
      \seq_clear:N \l_ropas_theme_missing_seq
      \bool_if:NT \l_ropas_theme_valid_bool
        {
          \seq_map_inline:Nn \c_ropas_theme_required_seq
            {
              \prop_if_in:NnF \l_ropas_theme_values_prop {##1}
                { \seq_put_right:Nn \l_ropas_theme_missing_seq {##1} }
            }
          \seq_if_empty:NF \l_ropas_theme_missing_seq
            {
              \bool_set_false:N \l_ropas_theme_valid_bool
              \ropas_class_error:nn
                { Theme~'\l_ropas_theme_name_tl'~is~missing~required~items:
                  ~\seq_use:Nn \l_ropas_theme_missing_seq {,~} }
                { Define~all~theme~items. }
            }
        }
      \bool_if:NT \l_ropas_theme_valid_bool
        {
          \int_gincr:N \g_ropas_theme_id_int
          \prop_gput:NVx \g_ropas_themes_prop \l_ropas_theme_name_tl
            { \int_use:N \g_ropas_theme_id_int }
          \prop_map_inline:Nn \l_ropas_theme_values_prop
            {
              \prop_gput:Nxx \g_ropas_theme_values_prop
                { theme/\int_use:N \g_ropas_theme_id_int/##1 }
                { \exp_not:n {##2} }
            }
        }
    \group_end:
  }

\cs_new_protected:Npn \ropas_theme_get:nN #1#2
  {
    \prop_get:NxN \g_ropas_theme_values_prop
      { theme/\l_ropas_theme_id_tl/#1 } #2
  }

\cs_new_protected:Npn \ropas_set_theme:n #1
  {
    \prop_get:NnNTF \g_ropas_themes_prop {#1} \l_ropas_theme_id_tl
      {
        \ropas_theme_get:nN {paper-margin-side} \l_tmpa_tl
        \dim_gset:Nn \g_ropas_body_side_dim {\l_tmpa_tl}
        \ropas_theme_get:nN {header-background} \l_tmpa_tl
        \tl_gset:NV \g_ropas_header_background_tl \l_tmpa_tl
        \ropas_theme_get:nN {header-margin-top} \l_tmpa_tl
        \dim_gset:Nn \g_ropas_header_top_dim {\l_tmpa_tl}
        \ropas_theme_get:nN {header-margin-bottom} \l_tmpa_tl
        \dim_gset:Nn \g_ropas_header_bottom_dim {\l_tmpa_tl}
        \ropas_theme_get:nN {header-leading} \l_tmpa_tl
        \dim_gset:Nn \g_ropas_header_leading_dim {\l_tmpa_tl}
        \ropas_theme_get:nN {title-size} \l_tmpa_tl
        \dim_gset:Nn \g_ropas_title_size_dim {\l_tmpa_tl}
        \ropas_theme_get:nN {title-colour} \l_tmpa_tl
        \tl_gset:NV \g_ropas_title_colour_tl \l_tmpa_tl
        \ropas_theme_get:nN {subtitle-size} \l_tmpa_tl
        \dim_gset:Nn \g_ropas_subtitle_size_dim {\l_tmpa_tl}
        \ropas_theme_get:nN {subtitle-colour} \l_tmpa_tl
        \tl_gset:NV \g_ropas_subtitle_colour_tl \l_tmpa_tl
        \ropas_theme_get:nN {author-size} \l_tmpa_tl
        \dim_gset:Nn \g_ropas_author_size_dim {\l_tmpa_tl}
        \ropas_theme_get:nN {author-colour} \l_tmpa_tl
        \tl_gset:NV \g_ropas_author_colour_tl \l_tmpa_tl
        \ropas_theme_get:nN {institute-size} \l_tmpa_tl
        \dim_gset:Nn \g_ropas_institute_size_dim {\l_tmpa_tl}
        \ropas_theme_get:nN {institute-colour} \l_tmpa_tl
        \tl_gset:NV \g_ropas_institute_colour_tl \l_tmpa_tl
        \ropas_theme_get:nN {body-background} \l_tmpa_tl
        \tl_gset:NV \g_ropas_body_background_tl \l_tmpa_tl
        \ropas_theme_get:nN {body-margin-top} \l_tmpa_tl
        \dim_gset:Nn \g_ropas_body_top_dim {\l_tmpa_tl}
        \ropas_theme_get:nN {body-margin-bottom} \l_tmpa_tl
        \dim_gset:Nn \g_ropas_body_bottom_dim {\l_tmpa_tl}
        \ropas_theme_get:nN {logo-height} \l_tmpa_tl
        \dim_gset:Nn \g_ropas_logo_height_dim {\l_tmpa_tl}
        \ropas_theme_get:nN {block-colour} \l_tmpa_tl
        \tl_gset:NV \g_ropas_cell_bg_colour_tl \l_tmpa_tl
        \ropas_theme_get:nN {block-sep} \l_tmpa_tl
        \dim_gset:Nn \g_ropas_cell_gap_dim {\l_tmpa_tl}
        \ropas_theme_get:nN {block-margin} \l_tmpa_tl
        \dim_gset:Nn \g_ropas_cell_margin_dim {\l_tmpa_tl}
        \ropas_theme_get:nN {block-corner-radius} \l_tmpa_tl
        \dim_gset:Nn \g_ropas_cell_corner_radius_dim {\l_tmpa_tl}
        \ropas_theme_get:nN {block-align} \l_tmpa_tl
        \tl_gset:NV \g_ropas_align_tl \l_tmpa_tl
        \ropas_theme_get:nN {block-column-count} \l_tmpa_tl
        \int_gset:Nn \g_ropas_column_num_int {\l_tmpa_tl}
        \ropas_theme_get:nN {block-column-sep} \l_tmpa_tl
        \dim_gset:Nn \g_ropas_column_gap_dim {\l_tmpa_tl}
        \ropas_theme_get:nN {block-leading} \l_tmpa_tl
        \dim_gset:Nn \g_ropas_text_leading_dim {\l_tmpa_tl}
        \ropas_theme_get:nN {block-paragraph-sep} \l_tmpa_tl
        \dim_gset:Nn \g_ropas_paragraph_leading_dim {\l_tmpa_tl}
        \ropas_theme_get:nN {block-paragraph-indent} \l_tmpa_tl
        \dim_gset:Nn \g_ropas_paragraph_indent_dim {\l_tmpa_tl}
        \ropas_theme_get:nN {blocktitle-size} \l_tmpa_tl
        \dim_gset:Nn \g_ropas_cell_title_size_dim {\l_tmpa_tl}
        \ropas_theme_get:nN {blocktitle-colour} \l_tmpa_tl
        \tl_gset:NV \g_ropas_cell_title_colour_tl \l_tmpa_tl
        \ropas_theme_get:nN {sectiontitle-size} \l_tmpa_tl
        \dim_gset:Nn \g_ropas_section_title_size_dim {\l_tmpa_tl}
        \ropas_theme_get:nN {sectiontitle-colour} \l_tmpa_tl
        \tl_gset:NV \g_ropas_section_title_colour_tl \l_tmpa_tl
        \ropas_theme_get:nN {text-size} \l_tmpa_tl
        \dim_gset:Nn \g_ropas_text_size_dim {\l_tmpa_tl}
        \ropas_theme_get:nN {text-colour} \l_tmpa_tl
        \tl_gset:NV \g_ropas_text_colour_tl \l_tmpa_tl
      }
      {
        \ropas_class_error:nn { Unknown~theme~'#1' }
          { Define~the~theme~before~selecting~it. }
      }
  }

\ropas_define_theme:nnn {default}{}{}

\exp_args:NV \ropas_parse_paper:n \g_ropas_class_paper_tl
\exp_args:NV \ropas_set_theme:n \g_ropas_class_theme_tl
\ropas_reset_default_size_base:

% --------------------------------------------------------------------------
% Public preamble commands
% --------------------------------------------------------------------------

\cs_new_protected:Npn \ropas_sync_geometry:
  {
    \geometry
      {
        paperwidth=\dim_use:N \g_ropas_paper_width_dim,
        paperheight=\dim_use:N \g_ropas_paper_height_dim,
        margin=0pt,
        noheadfoot
      }
    \dim_gset_eq:NN \paperwidth \g_ropas_paper_width_dim
    \dim_gset_eq:NN \paperheight \g_ropas_paper_height_dim
  }
\ropas_sync_geometry:

\NewDocumentCommand \posterSetPaperSize { O{portrait} m }
  {
    \seq_set_split:Nnn \l_tmpa_seq { , } {#2}
    \int_compare:nNnTF { \seq_count:N \l_tmpa_seq } = { 1 }
      {
        \ropas_set_named_paper:nn
          { \tl_trim_spaces:n {#2} }
          { \tl_trim_spaces:n {#1} }
      }
      {
        \int_compare:nNnTF { \seq_count:N \l_tmpa_seq } = { 2 }
          {
            \ropas_set_custom_paper:nn
              { \tl_trim_spaces:e { \seq_item:Nn \l_tmpa_seq {1} } }
              { \tl_trim_spaces:e { \seq_item:Nn \l_tmpa_seq {2} } }
          }
          {
            \ropas_class_error:nn { Invalid~paper~size~'#2' }
              { Supply~a~paper~name~or~exactly~two~lengths. }
          }
      }
    \ropas_sync_geometry:
  }

\NewDocumentCommand \posterSetPaperWidth { m }
  {
    \ropas_set_positive_dim:Nnn \g_ropas_paper_width_dim
      { Paper~width } {#1}
    \ropas_sync_geometry:
  }

\NewDocumentCommand \posterSetPaperHeight { m }
  {
    \ropas_set_positive_dim:Nnn \g_ropas_paper_height_dim
      { Paper~height } {#1}
    \ropas_sync_geometry:
  }

\NewDocumentCommand \posterSetTheme { m }
  {
    \exp_args:Ne \ropas_set_theme:n { \tl_trim_spaces:n {#1} }
    \ropas_reset_default_size_base:
  }

\NewDocumentCommand \posterDefineTheme { m O{} m }
  { \ropas_define_theme:nnn {#1}{#2}{#3} }

\NewDocumentCommand \posterSetPaperMarginSide { m }
  { \ropas_set_nonnegative_dim:Nnn \g_ropas_body_side_dim
      { Paper~side~margin } {#1} }

\NewDocumentCommand \posterSetHeaderBackground { m }
  { \tl_gset:Nn \g_ropas_header_background_tl {#1} }
\NewDocumentCommand \posterSetBodyBackground { m }
  { \tl_gset:Nn \g_ropas_body_background_tl {#1} }

\NewDocumentCommand \posterSetHeaderMarginTop { m }
  { \ropas_set_nonnegative_dim:Nnn \g_ropas_header_top_dim
      { Header~top~margin } {#1} }

\NewDocumentCommand \posterSetHeaderMarginBottom { m }
  { \ropas_set_nonnegative_dim:Nnn \g_ropas_header_bottom_dim
      { Header~bottom~margin } {#1} }

\NewDocumentCommand \posterSetHeaderLeading { m }
  { \ropas_set_nonnegative_dim:Nnn \g_ropas_header_leading_dim
      { Header~leading } {#1} }
\NewDocumentCommand \posterSetTitleSize { m }
  { \ropas_set_positive_dim:Nnn \g_ropas_title_size_dim
      { Title~size } {#1} }
\NewDocumentCommand \posterSetTitleColour { m }
  { \tl_gset:Nn \g_ropas_title_colour_tl {#1} }
\NewDocumentCommand \posterSetSubtitleSize { m }
  { \ropas_set_positive_dim:Nnn \g_ropas_subtitle_size_dim
      { Subtitle~size } {#1} }
\NewDocumentCommand \posterSetSubtitleColour { m }
  { \tl_gset:Nn \g_ropas_subtitle_colour_tl {#1} }
\NewDocumentCommand \posterSetAuthorSize { m }
  { \ropas_set_positive_dim:Nnn \g_ropas_author_size_dim
      { Author~size } {#1} }
\NewDocumentCommand \posterSetAuthorColour { m }
  { \tl_gset:Nn \g_ropas_author_colour_tl {#1} }
\NewDocumentCommand \posterSetInstituteSize { m }
  { \ropas_set_positive_dim:Nnn \g_ropas_institute_size_dim
      { Institute~size } {#1} }
\NewDocumentCommand \posterSetInstituteColour { m }
  { \tl_gset:Nn \g_ropas_institute_colour_tl {#1} }

\NewDocumentCommand \posterSetBodyMarginTop { m }
  { \ropas_set_nonnegative_dim:Nnn \g_ropas_body_top_dim
      { Body~top~margin } {#1} }

\NewDocumentCommand \posterSetBodyMarginBottom { m }
  { \ropas_set_nonnegative_dim:Nnn \g_ropas_body_bottom_dim
      { Body~bottom~margin } {#1} }

\NewDocumentCommand \posterSetBlockColour { m }
  { \tl_gset:Nn \g_ropas_cell_bg_colour_tl {#1} }
\NewDocumentCommand \posterSetBlockSep { m }
  { \ropas_set_nonnegative_dim:Nnn \g_ropas_cell_gap_dim
      { Block~separation } {#1} }
\NewDocumentCommand \posterSetBlockMargin { m }
  { \ropas_set_nonnegative_dim:Nnn \g_ropas_cell_margin_dim
      { Block~margin } {#1} }
\NewDocumentCommand \posterSetBlockCornerRadius { m }
  { \ropas_set_nonnegative_dim:Nnn \g_ropas_cell_corner_radius_dim
      { Block~corner~radius } {#1} }
\NewDocumentCommand \posterSetBlockAlign { m }
  {
    \str_case:nnF {#1}
      {
        {top}{\tl_gset:Nn \g_ropas_align_tl {top}}
        {centre}{\tl_gset:Nn \g_ropas_align_tl {centre}}
        {center}{\tl_gset:Nn \g_ropas_align_tl {centre}}
        {bottom}{\tl_gset:Nn \g_ropas_align_tl {bottom}}
      }
      { \ropas_class_error:nn { Invalid~block~alignment~'#1' }
          { Use~top,~centre/center,~or~bottom. } }
  }
\NewDocumentCommand \posterSetBlockColumnCount { m }
  { \ropas_set_positive_int:Nnn \g_ropas_column_num_int
      { Block~column~count } {#1} }
\NewDocumentCommand \posterSetBlockColumnSep { m }
  { \ropas_set_nonnegative_dim:Nnn \g_ropas_column_gap_dim
      { Block~column~separation } {#1} }
\NewDocumentCommand \posterSetBlockLeading { m }
  {
    \ropas_set_nonnegative_dim:Nnn \g_ropas_text_leading_dim
      { Block~leading } {#1}
    \ropas_reset_default_size_base:
  }
\NewDocumentCommand \posterSetBlockParagraphSep { m }
  { \ropas_set_nonnegative_dim:Nnn \g_ropas_paragraph_leading_dim
      { Block~paragraph~separation } {#1} }
\NewDocumentCommand \posterSetBlockParagraphIndent { m }
  { \ropas_set_nonnegative_dim:Nnn \g_ropas_paragraph_indent_dim
      { Block~paragraph~indent } {#1} }
\NewDocumentCommand \posterSetBlocktitleSize { m }
  { \ropas_set_positive_dim:Nnn \g_ropas_cell_title_size_dim
      { Blocktitle~size } {#1} }
\NewDocumentCommand \posterSetBlocktitleColour { m }
  { \tl_gset:Nn \g_ropas_cell_title_colour_tl {#1} }
\NewDocumentCommand \posterSetSectiontitleSize { m }
  { \ropas_set_positive_dim:Nnn \g_ropas_section_title_size_dim
      { Sectiontitle~size } {#1} }
\NewDocumentCommand \posterSetSectiontitleColour { m }
  { \tl_gset:Nn \g_ropas_section_title_colour_tl {#1} }
\NewDocumentCommand \posterSetTextSize { m }
  {
    \ropas_set_positive_dim:Nnn \g_ropas_text_size_dim
      { Text~size } {#1}
    \ropas_reset_default_size_base:
  }
\NewDocumentCommand \posterSetTextColour { m }
  { \tl_gset:Nn \g_ropas_text_colour_tl {#1} }
\cs_new_eq:NN \posterSetTitleColor \posterSetTitleColour
\cs_new_eq:NN \posterSetSubtitleColor \posterSetSubtitleColour
\cs_new_eq:NN \posterSetAuthorColor \posterSetAuthorColour
\cs_new_eq:NN \posterSetInstituteColor \posterSetInstituteColour
\cs_new_eq:NN \posterSetBlockColor \posterSetBlockColour
\cs_new_eq:NN \posterSetBlocktitleColor \posterSetBlocktitleColour
\cs_new_eq:NN \posterSetSectiontitleColor \posterSetSectiontitleColour
\cs_new_eq:NN \posterSetTextColor \posterSetTextColour

\keys_define:nn { ropas-poster / title }
  {
    size .code:n = { \posterSetTitleSize{#1} },
    colour .code:n = { \posterSetTitleColour{#1} },
    unknown .code:n =
      { \ropas_class_error:nn { Unknown~title~option~'\l_keys_key_str' }
          { Use~size~or~colour. } }
  }
\keys_define:nn { ropas-poster / title }
  { color .meta:n = {colour={#1}} }
\keys_define:nn { ropas-poster / subtitle }
  {
    size .code:n = { \posterSetSubtitleSize{#1} },
    colour .code:n = { \posterSetSubtitleColour{#1} },
    unknown .code:n =
      { \ropas_class_error:nn { Unknown~subtitle~option~'\l_keys_key_str' }
          { Use~size~or~colour. } }
  }
\keys_define:nn { ropas-poster / subtitle }
  { color .meta:n = {colour={#1}} }
\keys_define:nn { ropas-poster / author }
  {
    size .code:n = { \posterSetAuthorSize{#1} },
    colour .code:n = { \posterSetAuthorColour{#1} },
    unknown .code:n =
      { \ropas_class_error:nn { Unknown~author~option~'\l_keys_key_str' }
          { Use~size~or~colour. } }
  }
\keys_define:nn { ropas-poster / author }
  { color .meta:n = {colour={#1}} }
\keys_define:nn { ropas-poster / institute }
  {
    size .code:n = { \posterSetInstituteSize{#1} },
    colour .code:n = { \posterSetInstituteColour{#1} },
    unknown .code:n =
      { \ropas_class_error:nn { Unknown~institute~option~'\l_keys_key_str' }
          { Use~size~or~colour. } }
  }
\keys_define:nn { ropas-poster / institute }
  { color .meta:n = {colour={#1}} }

\cs_new_protected:Npn \ropas_reject_header_notes:n #1
  {
    \tl_if_in:nnT {#1}{\footnote}
      {\ropas_class_error:nn { Footnote~in~poster~header }
        { Footnotes~are~not~allowed~in~header~metadata. }}
    \tl_if_in:nnT {#1}{\footnotemark}
      {\ropas_class_error:nn { Footnote~in~poster~header }
        { Footnotes~are~not~allowed~in~header~metadata. }}
    \tl_if_in:nnT {#1}{\footnotetext}
      {\ropas_class_error:nn { Footnote~in~poster~header }
        { Footnotes~are~not~allowed~in~header~metadata. }}
  }

\cs_new_protected:Npn \ropas_append_header_people:Nn #1#2
  {
    \seq_set_split:Nnn \l_tmpa_seq {\and} {#2}
    \seq_map_inline:Nn \l_tmpa_seq
      {
        \tl_set:Nx \l_tmpa_tl {\tl_trim_spaces:n {##1}}
        \tl_if_blank:VF \l_tmpa_tl
          {
            \tl_if_blank:VF #1 {\tl_gput_right:Nn #1 {\qquad}}
            \tl_gput_right:NV #1 \l_tmpa_tl
          }
      }
  }

\DeclareDocumentCommand \title { O{} m }
  { \ropas_keys_set_last:nn { ropas-poster / title } {#1}
    \ropas_reject_header_notes:n {#2}
    \tl_gset:Nn \g_ropas_title_tl {#2} }
\NewDocumentCommand \subtitle { O{} m }
  { \ropas_keys_set_last:nn { ropas-poster / subtitle } {#1}
    \ropas_reject_header_notes:n {#2}
    \tl_gset:Nn \g_ropas_subtitle_tl {#2} }
\DeclareDocumentCommand \author { O{} m }
  { \ropas_keys_set_last:nn { ropas-poster / author } {#1}
    \ropas_reject_header_notes:n {#2}
    \ropas_append_header_people:Nn \g_ropas_author_tl {#2} }
\NewDocumentCommand \institute { O{} m }
  { \ropas_keys_set_last:nn { ropas-poster / institute } {#1}
    \ropas_reject_header_notes:n {#2}
    \ropas_append_header_people:Nn \g_ropas_institute_tl {#2} }

\NewDocumentCommand \logos { O{30mm} m }
  {
    \ropas_set_nonnegative_dim:Nnn \g_ropas_logo_height_dim
      { Logo~height } {#1}
    \seq_gclear:N \g_ropas_logos_seq
    \clist_map_inline:nn {#2}
      {
        \tl_if_blank:nF {##1}
          { \seq_gput_right:Nx \g_ropas_logos_seq { \tl_trim_spaces:n {##1} } }
      }
  }

% The public logo interface appends, so separate calls and a comma list have
% the same meaning.  A brace-protected comma is kept inside one filename by
% the clist parser.
\NewDocumentCommand \logo { m }
  {
    \clist_map_inline:nn {#1}
      {
        \tl_if_blank:nF {##1}
          { \seq_gput_right:Nx \g_ropas_logos_seq
              { \tl_trim_spaces:n {##1} } }
      }
  }

\NewDocumentCommand \posterSetLogoHeight { m }
  { \ropas_set_positive_dim:Nnn \g_ropas_logo_height_dim
      { Logo~height } {#1} }

% --------------------------------------------------------------------------
% Public-interface boundary with article
% --------------------------------------------------------------------------

% Preserve the familiar size names, but make their sizes relative to the
% active poster component.  The font-size proportions are those measured from
% the repository's acmart.cls in acmsmall mode.  The same single proportion is
% applied to the font size and to the independently configured leading, so the
% complete baseline distance scales uniformly.
\DeclareDocumentCommand \tiny { }
  { \ropas_select_relative_size:n { 0.6 } }
\DeclareDocumentCommand \scriptsize { }
  { \ropas_select_relative_size:n { 0.7 } }
\DeclareDocumentCommand \footnotesize { }
  { \ropas_select_relative_size:n { 0.8 } }
\DeclareDocumentCommand \small { }
  { \ropas_select_relative_size:n { 0.9 } }
\DeclareDocumentCommand \normalsize { }
  { \ropas_select_relative_size:n { 1 } }
\DeclareDocumentCommand \large { }
  { \ropas_select_relative_size:n { 1.095 } }
\DeclareDocumentCommand \Large { }
  { \ropas_select_relative_size:n { 1.2 } }
\DeclareDocumentCommand \LARGE { }
  { \ropas_select_relative_size:n { 1.44 } }
\DeclareDocumentCommand \huge { }
  { \ropas_select_relative_size:n { 1.728 } }
\DeclareDocumentCommand \Huge { }
  { \ropas_select_relative_size:n { 2.074 } }

\cs_new_protected:Npn \ropas_article_command_error:n #1
  {
    \ropas_class_error:nn
      { article~command~'#1'~is~not~available~in~ropas-poster }
      { Use~the~poster-specific~interface~instead. }
  }

\cs_new_protected:Npn \ropas_article_environment_error:n #1
  {
    \ropas_class_error:nn
      { article~environment~'#1'~is~not~available~in~ropas-poster }
      { Use~postergrid,~posterblock,~or~ordinary~block~content~instead. }
  }

% Article's title production, section hierarchy, contents, bibliography and
% index interfaces have no poster meaning.  Keep the control sequences
% defined so misuse produces a precise class error instead of a generic
% undefined-control-sequence diagnostic.
\DeclareDocumentCommand \maketitle { }
  { \ropas_article_command_error:n { maketitle } }
\DeclareDocumentCommand \part { s o m }
  { \ropas_article_command_error:n { part } }
\DeclareDocumentCommand \section { s o m }
  { \ropas_article_command_error:n { section } }
\DeclareDocumentCommand \subsection { s o m }
  { \ropas_article_command_error:n { subsection } }
\DeclareDocumentCommand \subsubsection { s o m }
  { \ropas_article_command_error:n { subsubsection } }
\DeclareDocumentCommand \paragraph { s o m }
  { \ropas_article_command_error:n { paragraph } }
\DeclareDocumentCommand \subparagraph { s o m }
  { \ropas_article_command_error:n { subparagraph } }
\DeclareDocumentCommand \appendix { }
  { \ropas_article_command_error:n { appendix } }
\DeclareDocumentCommand \tableofcontents { }
  { \ropas_article_command_error:n { tableofcontents } }
\DeclareDocumentCommand \listoffigures { }
  { \ropas_article_command_error:n { listoffigures } }
\DeclareDocumentCommand \listoftables { }
  { \ropas_article_command_error:n { listoftables } }
\DeclareDocumentCommand \newblock { }
  { \ropas_article_command_error:n { newblock } }
\DeclareDocumentCommand \subitem { }
  { \ropas_article_command_error:n { subitem } }
\DeclareDocumentCommand \subsubitem { }
  { \ropas_article_command_error:n { subsubitem } }
\DeclareDocumentCommand \indexspace { }
  { \ropas_article_command_error:n { indexspace } }

% Legacy article font switches are intentionally unavailable.  Current LaTeX
% font declarations such as \rmfamily and \bfseries remain kernel features.
\DeclareDocumentCommand \rm { }
  { \ropas_article_command_error:n { rm } }
\DeclareDocumentCommand \sf { }
  { \ropas_article_command_error:n { sf } }
\DeclareDocumentCommand \tt { }
  { \ropas_article_command_error:n { tt } }
\DeclareDocumentCommand \bf { }
  { \ropas_article_command_error:n { bf } }
\DeclareDocumentCommand \it { }
  { \ropas_article_command_error:n { it } }
\DeclareDocumentCommand \sl { }
  { \ropas_article_command_error:n { sl } }
\DeclareDocumentCommand \sc { }
  { \ropas_article_command_error:n { sc } }
\DeclareDocumentCommand \cal { }
  { \ropas_article_command_error:n { cal } }
\DeclareDocumentCommand \mit { }
  { \ropas_article_command_error:n { mit } }

% Retain class-owned numbering hooks required by equations, figures, tables,
% enumerate and itemize.  All other article hierarchy-formatting hooks fail.
\DeclareDocumentCommand \theequation { } { \arabic{equation} }
\DeclareDocumentCommand \thefigure { } { \arabic{figure} }
\DeclareDocumentCommand \thetable { } { \arabic{table} }
\DeclareDocumentCommand \figurename { } { Figure }
\DeclareDocumentCommand \tablename { } { Table }
\DeclareDocumentCommand \theenumi { } { \arabic{enumi} }
\DeclareDocumentCommand \theenumii { } { \alph{enumii} }
\DeclareDocumentCommand \theenumiii { } { \roman{enumiii} }
\DeclareDocumentCommand \theenumiv { } { \Alph{enumiv} }
\DeclareDocumentCommand \labelenumi { } { (\theenumi) }
\DeclareDocumentCommand \labelenumii { } { (\theenumii) }
\DeclareDocumentCommand \labelenumiii { } { (\theenumiii) }
\DeclareDocumentCommand \labelenumiv { } { (\theenumiv) }
\DeclareDocumentCommand \labelitemi { } { $\m@th\bullet$ }
\DeclareDocumentCommand \labelitemii { } { \bfseries -- }
\DeclareDocumentCommand \labelitemiii { } { $\m@th\ast$ }
\DeclareDocumentCommand \labelitemiv { } { $\m@th\cdot$ }
\DeclareDocumentCommand \labelitemfont { } { \normalfont }

\DeclareDocumentCommand \thepart { }
  { \ropas_article_command_error:n { thepart } }
\DeclareDocumentCommand \thesection { }
  { \ropas_article_command_error:n { thesection } }
\DeclareDocumentCommand \thesubsection { }
  { \ropas_article_command_error:n { thesubsection } }
\DeclareDocumentCommand \thesubsubsection { }
  { \ropas_article_command_error:n { thesubsubsection } }
\DeclareDocumentCommand \theparagraph { }
  { \ropas_article_command_error:n { theparagraph } }
\DeclareDocumentCommand \thesubparagraph { }
  { \ropas_article_command_error:n { thesubparagraph } }
\DeclareDocumentCommand \descriptionlabel { m }
  { \hspace\labelsep\normalfont\bfseries #1 }

\cs_set_protected:Npn \sectionmark #1
  { \ropas_article_command_error:n { sectionmark } }
\cs_set_protected:Npn \subsectionmark #1
  { \ropas_article_command_error:n { subsectionmark } }

\DeclareDocumentCommand \contentsname { }
  { \ropas_article_command_error:n { contentsname } }
\DeclareDocumentCommand \listfigurename { }
  { \ropas_article_command_error:n { listfigurename } }
\DeclareDocumentCommand \listtablename { }
  { \ropas_article_command_error:n { listtablename } }
\DeclareDocumentCommand \refname { }
  { \ropas_article_command_error:n { refname } }
\DeclareDocumentCommand \indexname { }
  { \ropas_article_command_error:n { indexname } }
\DeclareDocumentCommand \partname { }
  { \ropas_article_command_error:n { partname } }
\DeclareDocumentCommand \appendixname { }
  { \ropas_article_command_error:n { appendixname } }
\DeclareDocumentCommand \abstractname { }
  { \ropas_article_command_error:n { abstractname } }

% Block the two page-style names supplied specifically by article.  The
% poster document itself always uses its own empty page style.
\cs_set_protected:cpn { ps@headings }
  { \ropas_article_command_error:n { pagestyle/headings } }
\cs_set_protected:cpn { ps@myheadings }
  { \ropas_article_command_error:n { pagestyle/myheadings } }

\NewDocumentCommand \sectiontitle { m }
  {
    \ropas_class_error:nn
      { sectiontitle~is~only~available~inside~posterblock }
      { Move~sectiontitle~into~an~ordinary~posterblock. }
  }
\DeclareDocumentCommand \columnbreak { }
  { \ropas_class_error:nn
      { columnbreak~is~only~available~in~a~body~block }
      { Place~columnbreak~inside~document~or~posterblock~body. } }

\DeclareDocumentEnvironment { titlepage } { +b }
  { \ropas_article_environment_error:n { titlepage } }
  { }
\DeclareDocumentEnvironment { abstract } { +b }
  { \ropas_article_environment_error:n { abstract } }
  { }
\DeclareDocumentEnvironment { description } { }
  { \list{} { \labelwidth=0pt\itemindent=-\leftmargin
               \let\makelabel\descriptionlabel } }
  { \endlist }
\DeclareDocumentEnvironment { verse } { }
  { \let\\\@centercr
    \list{} { \itemsep=0pt\itemindent=-1.5em
              \listparindent=\itemindent
              \rightmargin=\leftmargin
              \advance\leftmargin 1.5em }\item\relax }
  { \endlist }
\DeclareDocumentEnvironment { quotation } { }
  { \list{} { \listparindent=\l_ropas_paragraph_indent_dim
              \itemindent=\listparindent
              \rightmargin=\leftmargin\parsep=0pt }\item\relax }
  { \endlist }
\DeclareDocumentEnvironment { quote } { }
  { \list{} { \rightmargin=\leftmargin\itemindent=0pt }\item\relax }
  { \endlist }
\DeclareDocumentEnvironment { thebibliography } { m +b }
  { \ropas_article_environment_error:n { thebibliography } }
  { }
\DeclareDocumentEnvironment { theindex } { +b }
  { \ropas_article_environment_error:n { theindex } }
  { }

% Poster floats are confined to their owner block, not the physical page.
\bool_new:N \l_ropas_public_float_valid_bool
\bool_new:N \l_ropas_float_star_bool
\cs_new_protected:Npn \ropas_public_float_begin:nnn #1#2#3
  {
    \str_if_eq:nnTF {#3}{true}
      {\bool_set_true:N \l_ropas_float_star_bool}
      {\bool_set_false:N \l_ropas_float_star_bool}
    \bool_set_false:N \l_ropas_public_float_valid_bool
    \bool_set:Nn \l_tmpa_bool
      { \str_if_eq_p:Vn \l_ropas_context_tl {block}
        || \str_if_eq_p:Vn \l_ropas_context_tl {document} }
    \bool_if:NTF \l_tmpa_bool
      {
        \bool_set_true:N \l_ropas_public_float_valid_bool
        \@xfloat{#1}[#2]
      }
      {
        \ropas_class_error:nn
          { #1~is~only~available~inside~body~content }
          { Move~the~#1~environment~into~document~or~posterblock. }
      }
  }

\cs_new_protected:Npn \ropas_public_float_end:
  { \bool_if:NT \l_ropas_public_float_valid_bool { \end@float } }

\DeclareDocumentEnvironment { figure } { O{tb} }
  { \ropas_public_float_begin:nnn { figure } {#1}{false} }
  { \ropas_public_float_end: }
\DeclareDocumentEnvironment { figure* } { O{tb} }
  { \ropas_public_float_begin:nnn { figure } {#1}{true} }
  { \ropas_public_float_end: }
\DeclareDocumentEnvironment { table } { O{tb} }
  { \ropas_public_float_begin:nnn { table } {#1}{false} }
  { \ropas_public_float_end: }
\DeclareDocumentEnvironment { table* } { O{tb} }
  { \ropas_public_float_begin:nnn { table } {#1}{true} }
  { \ropas_public_float_end: }

\cs_new_protected:Npn \ropas_late_preamble_command:
  { \ropas_class_error:nn
      { Preamble~command~used~after~document~began }
      { Move~this~command~before~\string\begin{document}. } }
\AddToHook { begindocument/end }
  {
    \clist_map_inline:nn
      {
        posterSetPaperSize,posterSetPaperWidth,posterSetPaperHeight,
        posterSetTheme,posterDefineTheme,posterSetPaperMarginSide,
        posterSetHeaderBackground,posterSetBodyBackground,
        posterSetHeaderMarginTop,posterSetHeaderMarginBottom,
        posterSetHeaderLeading,posterSetTitleSize,
        posterSetTitleColour,posterSetTitleColor,
        posterSetSubtitleSize,posterSetSubtitleColour,posterSetSubtitleColor,
        posterSetAuthorSize,posterSetAuthorColour,posterSetAuthorColor,
        posterSetInstituteSize,posterSetInstituteColour,posterSetInstituteColor,
        posterSetBodyMarginTop,posterSetBodyMarginBottom,
        posterSetBlockColour,posterSetBlockColor,
        posterSetBlockSep,posterSetBlockMargin,
        posterSetBlockCornerRadius,posterSetBlockAlign,
        posterSetBlockColumnCount,posterSetBlockColumnSep,
        posterSetBlockLeading,posterSetBlockParagraphSep,
        posterSetBlockParagraphIndent,posterSetBlocktitleSize,
        posterSetBlocktitleColour,posterSetBlocktitleColor,
        posterSetSectiontitleSize,
        posterSetSectiontitleColour,posterSetSectiontitleColor,
        posterSetTextSize,posterSetTextColour,posterSetTextColor,
        posterSetLogoHeight,title,subtitle,
        author,institute,logo,logos
      }
      {\cs_gset_eq:cN {#1} \ropas_late_preamble_command:}
  }

\AddToHook { shipout/background }
  { \box_use:N \g_ropas_background_box }

% Some otherwise compatible packages leave harmless material for a final
% output-routine cycle.  A poster has exactly one physical sheet, so suppress
% every shipout after the first one at the kernel shipout boundary.
\int_new:N \g_ropas_shipout_count_int
\AddToHook { shipout/before }
  {
    \int_gincr:N \g_ropas_shipout_count_int
    \int_compare:nNnT { \g_ropas_shipout_count_int } > { 1 }
      { \DiscardShipoutBox }
  }

% --------------------------------------------------------------------------
% Grid data and option parsing
% --------------------------------------------------------------------------

\prop_new:N \g_ropas_data_prop
\cs_generate_variant:Nn \prop_get:NnN { NxN }
\cs_generate_variant:Nn \prop_get:NnNTF { NxNTF }
\cs_generate_variant:Nn \prop_gput:Nnn { Nxn, NxV, Nxx }
\cs_generate_variant:Nn \prop_if_in:NnTF { NxTF }
\cs_generate_variant:Nn \seq_set_item:Nnn { NnV, Nnx }
\int_new:N \g_ropas_grid_id_int
\int_new:N \g_ropas_child_id_int
\int_new:N \l_ropas_current_grid_int
\bool_new:N \l_ropas_register_bool
\tl_new:N \l_ropas_child_tl
\tl_new:N \l_ropas_new_grid_tl
\tl_new:N \g_ropas_return_grid_tl
\tl_new:N \l_ropas_grid_tl

\int_new:N \l_ropas_rows_int
\int_new:N \l_ropas_cols_int
\tl_new:N \l_ropas_row_ratio_tl
\tl_new:N \l_ropas_col_ratio_tl
\bool_new:N \l_ropas_row_ratio_given_bool
\bool_new:N \l_ropas_col_ratio_given_bool
\tl_new:N \l_ropas_colour_tl
\dim_new:N \l_ropas_gap_dim
\dim_new:N \l_ropas_margin_dim
\dim_new:N \l_ropas_corner_radius_dim
\dim_new:N \l_ropas_column_gap_dim
\int_new:N \l_ropas_column_num_int
\dim_new:N \l_ropas_text_leading_dim
\dim_new:N \l_ropas_paragraph_leading_dim
\dim_new:N \l_ropas_title_size_dim
\tl_new:N \l_ropas_title_colour_tl
\dim_new:N \l_ropas_section_title_size_dim
\tl_new:N \l_ropas_section_title_colour_tl
\dim_new:N \l_ropas_text_size_dim
\tl_new:N \l_ropas_text_colour_tl
\dim_new:N \l_ropas_line_width_dim
\tl_new:N \l_ropas_line_colour_tl
\tl_new:N \l_ropas_align_tl

\cs_new_protected:Npn \ropas_local_nonnegative_dim:Nnn #1#2#3
  {
    \dim_set:Nn \l_tmpa_dim {#3}
    \dim_compare:nNnTF { \l_tmpa_dim } < { 0pt }
      { \ropas_class_error:nn { #2~must~be~non-negative }
          { Supply~a~LaTeX~length~greater~than~or~equal~to~zero. } }
      { \dim_set_eq:NN #1 \l_tmpa_dim }
  }

\cs_new_protected:Npn \ropas_local_positive_dim:Nnn #1#2#3
  {
    \dim_set:Nn \l_tmpa_dim {#3}
    \dim_compare:nNnTF { \l_tmpa_dim } > { 0pt }
      { \dim_set_eq:NN #1 \l_tmpa_dim }
      { \ropas_class_error:nn { #2~must~be~positive }
          { Supply~a~LaTeX~length~strictly~greater~than~zero. } }
  }

\cs_new_protected:Npn \ropas_local_positive_int:Nnn #1#2#3
  {
    \regex_match:nnTF { \A \s* [0-9]+ \s* \Z } {#3}
      {
        \int_compare:nNnTF {#3} > {0}
          { \int_set:Nn #1 {#3} }
          { \ropas_class_error:nn { #2~must~be~positive }
              { Supply~an~integer~strictly~greater~than~zero. } }
      }
      { \ropas_class_error:nn { #2~must~be~an~integer }
          { Supply~a~positive~integer. } }
  }

\keys_define:nn { ropas-poster / grid }
  {
    row-count .code:n =
      { \ropas_local_positive_int:Nnn \l_ropas_rows_int { row-count } {#1} },
    row-ratio .code:n =
      { \tl_set:Nn \l_ropas_row_ratio_tl {#1}
        \bool_set_true:N \l_ropas_row_ratio_given_bool },
    col-count .code:n =
      { \ropas_local_positive_int:Nnn \l_ropas_cols_int { col-count } {#1} },
    col-ratio .code:n =
      { \tl_set:Nn \l_ropas_col_ratio_tl {#1}
        \bool_set_true:N \l_ropas_col_ratio_given_bool },
    block-colour .code:n =
      { \ropas_validate_colour:n {#1}
        \tl_set:Nn \l_ropas_colour_tl {#1} },
    block-sep .code:n =
      { \ropas_local_nonnegative_dim:Nnn \l_ropas_gap_dim
          { block-sep } {#1} },
    block-margin .code:n =
      { \ropas_local_nonnegative_dim:Nnn \l_ropas_margin_dim
          { block-margin } {#1} },
    block-corner-radius .code:n =
      { \ropas_local_nonnegative_dim:Nnn \l_ropas_corner_radius_dim
          { block-corner-radius } {#1} },
    block-column-sep .code:n =
      { \ropas_local_nonnegative_dim:Nnn \l_ropas_column_gap_dim
          { block-column-sep } {#1} },
    block-column-count .code:n =
      { \ropas_local_positive_int:Nnn \l_ropas_column_num_int
          { block-column-count } {#1} },
    block-leading .code:n =
      { \ropas_local_nonnegative_dim:Nnn \l_ropas_text_leading_dim
          { block-leading } {#1} },
    block-align .code:n =
      {
        \str_case:nnF {#1}
          {
            {top}{\tl_set:Nn \l_ropas_align_tl {top}}
            {centre}{\tl_set:Nn \l_ropas_align_tl {centre}}
            {center}{\tl_set:Nn \l_ropas_align_tl {centre}}
            {bottom}{\tl_set:Nn \l_ropas_align_tl {bottom}}
          }
          { \ropas_class_error:nn { Invalid~block-align~'#1' }
              { Use~top,~centre/center,~or~bottom. } }
      },
    block-paragraph-sep .code:n =
      { \ropas_local_nonnegative_dim:Nnn \l_ropas_paragraph_leading_dim
          { block-paragraph-sep } {#1} },
    block-paragraph-indent .code:n =
      { \ropas_local_nonnegative_dim:Nnn \l_ropas_paragraph_indent_dim
          { block-paragraph-indent } {#1} },
    blocktitle-size .code:n =
      { \ropas_local_positive_dim:Nnn \l_ropas_title_size_dim
          { blocktitle-size } {#1} },
    blocktitle-colour .code:n =
      { \ropas_validate_colour:n {#1}
        \tl_set:Nn \l_ropas_title_colour_tl {#1} },
    sectiontitle-size .code:n =
      { \ropas_local_positive_dim:Nnn \l_ropas_section_title_size_dim
          { sectiontitle-size } {#1} },
    sectiontitle-colour .code:n =
      { \ropas_validate_colour:n {#1}
        \tl_set:Nn \l_ropas_section_title_colour_tl {#1} },
    text-size .code:n =
      { \ropas_local_positive_dim:Nnn \l_ropas_text_size_dim
          { text-size } {#1} },
    text-colour .code:n =
      { \ropas_validate_colour:n {#1}
        \tl_set:Nn \l_ropas_text_colour_tl {#1} },
    line-width .code:n =
      { \ropas_local_nonnegative_dim:Nnn \l_ropas_line_width_dim
          { line-width } {#1} },
    line-colour .code:n =
      { \ropas_validate_colour:n {#1}
        \tl_set:Nn \l_ropas_line_colour_tl {#1} },
    unknown .code:n =
      { \ropas_class_error:nn { Unknown~grid~option~'\l_keys_key_str' }
          { Consult~the~ropas-poster~grid~option~list. } }
  }

\keys_define:nn { ropas-poster / block }
  {
    colour .code:n =
      { \ropas_validate_colour:n {#1}
        \tl_set:Nn \l_ropas_colour_tl {#1} },
    margin .code:n =
      { \ropas_local_nonnegative_dim:Nnn \l_ropas_margin_dim { margin } {#1} },
    corner-radius .code:n =
      { \ropas_local_nonnegative_dim:Nnn \l_ropas_corner_radius_dim
          { corner-radius } {#1} },
    column-sep .code:n =
      { \ropas_local_nonnegative_dim:Nnn \l_ropas_column_gap_dim
          { column-sep } {#1} },
    column-count .code:n =
      { \ropas_local_positive_int:Nnn \l_ropas_column_num_int
          { column-count } {#1} },
    leading .code:n =
      { \ropas_local_nonnegative_dim:Nnn \l_ropas_text_leading_dim
          { leading } {#1} },
    align .code:n =
      {
        \str_case:nnF {#1}
          {
            {top}{\tl_set:Nn \l_ropas_align_tl {top}}
            {centre}{\tl_set:Nn \l_ropas_align_tl {centre}}
            {center}{\tl_set:Nn \l_ropas_align_tl {centre}}
            {bottom}{\tl_set:Nn \l_ropas_align_tl {bottom}}
          }
          { \ropas_class_error:nn { Invalid~align~'#1' }
              { Use~top,~centre/center,~or~bottom. } }
      },
    paragraph-sep .code:n =
      { \ropas_local_nonnegative_dim:Nnn \l_ropas_paragraph_leading_dim
          { paragraph-sep } {#1} },
    paragraph-indent .code:n =
      { \ropas_local_nonnegative_dim:Nnn \l_ropas_paragraph_indent_dim
          { paragraph-indent } {#1} },
    blocktitle-size .code:n =
      { \ropas_local_positive_dim:Nnn \l_ropas_title_size_dim
          { blocktitle-size } {#1} },
    blocktitle-colour .code:n =
      { \ropas_validate_colour:n {#1}
        \tl_set:Nn \l_ropas_title_colour_tl {#1} },
    sectiontitle-size .code:n =
      { \ropas_local_positive_dim:Nnn \l_ropas_section_title_size_dim
          { sectiontitle-size } {#1} },
    sectiontitle-colour .code:n =
      { \ropas_validate_colour:n {#1}
        \tl_set:Nn \l_ropas_section_title_colour_tl {#1} },
    text-size .code:n =
      { \ropas_local_positive_dim:Nnn \l_ropas_text_size_dim
          { text-size } {#1} },
    text-colour .code:n =
      { \ropas_validate_colour:n {#1}
        \tl_set:Nn \l_ropas_text_colour_tl {#1} },
    content-align .code:n =
      {
        \str_case:nnF {#1}
          {
            { top }    { \tl_set:Nn \l_ropas_align_tl { top } }
            { centre } { \tl_set:Nn \l_ropas_align_tl { centre } }
            { center } { \tl_set:Nn \l_ropas_align_tl { centre } }
            { bottom } { \tl_set:Nn \l_ropas_align_tl { bottom } }
          }
          { \ropas_class_error:nn { Unknown~block~content~alignment~'#1' }
              { Use~top,~centre/center,~or~bottom. } }
      },
    unknown .code:n =
      { \ropas_class_error:nn { Unknown~block~option~'\l_keys_key_str' }
          { Consult~the~ropas-poster~block~option~list. } }
  }
\keys_define:nn { ropas-poster / grid }
  {
    line-color .meta:n = {line-colour={#1}},
    block-color .meta:n = {block-colour={#1}},
    blocktitle-color .meta:n = {blocktitle-colour={#1}},
    sectiontitle-color .meta:n = {sectiontitle-colour={#1}},
    text-color .meta:n = {text-colour={#1}}
  }
\keys_define:nn { ropas-poster / block }
  {
    color .meta:n = {colour={#1}},
    blocktitle-color .meta:n = {blocktitle-colour={#1}},
    sectiontitle-color .meta:n = {sectiontitle-colour={#1}},
    text-color .meta:n = {text-colour={#1}}
  }

\cs_new_protected:Npn \ropas_load_style_from_globals:
  {
    \tl_set_eq:NN \l_ropas_colour_tl \g_ropas_cell_bg_colour_tl
    \dim_set_eq:NN \l_ropas_gap_dim \g_ropas_cell_gap_dim
    \dim_set_eq:NN \l_ropas_margin_dim \g_ropas_cell_margin_dim
    \dim_set_eq:NN \l_ropas_corner_radius_dim
      \g_ropas_cell_corner_radius_dim
    \dim_set_eq:NN \l_ropas_column_gap_dim \g_ropas_column_gap_dim
    \int_set_eq:NN \l_ropas_column_num_int \g_ropas_column_num_int
    \dim_set_eq:NN \l_ropas_text_leading_dim \g_ropas_text_leading_dim
    \dim_set_eq:NN \l_ropas_paragraph_leading_dim
      \g_ropas_paragraph_leading_dim
    \dim_set_eq:NN \l_ropas_paragraph_indent_dim
      \g_ropas_paragraph_indent_dim
    \tl_set_eq:NN \l_ropas_align_tl \g_ropas_align_tl
    \dim_set_eq:NN \l_ropas_title_size_dim \g_ropas_cell_title_size_dim
    \tl_set_eq:NN \l_ropas_title_colour_tl \g_ropas_cell_title_colour_tl
    \dim_set_eq:NN \l_ropas_section_title_size_dim
      \g_ropas_section_title_size_dim
    \tl_set_eq:NN \l_ropas_section_title_colour_tl
      \g_ropas_section_title_colour_tl
    \dim_set_eq:NN \l_ropas_text_size_dim \g_ropas_text_size_dim
    \tl_set_eq:NN \l_ropas_text_colour_tl \g_ropas_text_colour_tl
  }

\cs_new_protected:Npn \ropas_load_style:nn #1#2
  {
    \prop_get:NxN \g_ropas_data_prop { #1/#2/colour }
      \l_ropas_colour_tl
    \prop_get:NxN \g_ropas_data_prop { #1/#2/margin } \l_tmpa_tl
    \dim_set:Nn \l_ropas_margin_dim { \l_tmpa_tl }
    \prop_get:NxN \g_ropas_data_prop { #1/#2/corner-radius } \l_tmpa_tl
    \dim_set:Nn \l_ropas_corner_radius_dim { \l_tmpa_tl }
    \prop_get:NxN \g_ropas_data_prop { #1/#2/column-gap } \l_tmpa_tl
    \dim_set:Nn \l_ropas_column_gap_dim { \l_tmpa_tl }
    \prop_get:NxN \g_ropas_data_prop { #1/#2/column-num } \l_tmpa_tl
    \int_set:Nn \l_ropas_column_num_int { \l_tmpa_tl }
    \prop_get:NxN \g_ropas_data_prop { #1/#2/text-leading } \l_tmpa_tl
    \dim_set:Nn \l_ropas_text_leading_dim { \l_tmpa_tl }
    \prop_get:NxN \g_ropas_data_prop { #1/#2/paragraph-leading } \l_tmpa_tl
    \dim_set:Nn \l_ropas_paragraph_leading_dim { \l_tmpa_tl }
    \prop_get:NxN \g_ropas_data_prop { #1/#2/paragraph-indent } \l_tmpa_tl
    \dim_set:Nn \l_ropas_paragraph_indent_dim { \l_tmpa_tl }
    \prop_get:NxN \g_ropas_data_prop { #1/#2/title-size } \l_tmpa_tl
    \dim_set:Nn \l_ropas_title_size_dim { \l_tmpa_tl }
    \prop_get:NxN \g_ropas_data_prop { #1/#2/title-colour }
      \l_ropas_title_colour_tl
    \prop_get:NxN \g_ropas_data_prop { #1/#2/section-title-size } \l_tmpa_tl
    \dim_set:Nn \l_ropas_section_title_size_dim { \l_tmpa_tl }
    \prop_get:NxN \g_ropas_data_prop { #1/#2/section-title-colour }
      \l_ropas_section_title_colour_tl
    \prop_get:NxN \g_ropas_data_prop { #1/#2/text-size } \l_tmpa_tl
    \dim_set:Nn \l_ropas_text_size_dim { \l_tmpa_tl }
    \prop_get:NxN \g_ropas_data_prop { #1/#2/text-colour }
      \l_ropas_text_colour_tl
    \prop_get:NxN \g_ropas_data_prop { #1/#2/align } \l_ropas_align_tl
  }

\cs_new_protected:Npn \ropas_load_style_from_grid:n #1
  {
    \prop_get:NxN \g_ropas_data_prop { grid/#1/gap } \l_tmpa_tl
    \dim_set:Nn \l_ropas_gap_dim { \l_tmpa_tl }
    \ropas_load_style:nn { grid } {#1}
  }

\cs_new_protected:Npn \ropas_store_style:nn #1#2
  {
    \prop_gput:NxV \g_ropas_data_prop { #1/#2/colour }
      \l_ropas_colour_tl
    \prop_gput:Nxx \g_ropas_data_prop { #1/#2/margin }
      { \dim_use:N \l_ropas_margin_dim }
    \prop_gput:Nxx \g_ropas_data_prop { #1/#2/corner-radius }
      { \dim_use:N \l_ropas_corner_radius_dim }
    \prop_gput:Nxx \g_ropas_data_prop { #1/#2/column-gap }
      { \dim_use:N \l_ropas_column_gap_dim }
    \prop_gput:Nxx \g_ropas_data_prop { #1/#2/column-num }
      { \int_use:N \l_ropas_column_num_int }
    \prop_gput:Nxx \g_ropas_data_prop { #1/#2/text-leading }
      { \dim_use:N \l_ropas_text_leading_dim }
    \prop_gput:Nxx \g_ropas_data_prop { #1/#2/paragraph-leading }
      { \dim_use:N \l_ropas_paragraph_leading_dim }
    \prop_gput:Nxx \g_ropas_data_prop { #1/#2/paragraph-indent }
      { \dim_use:N \l_ropas_paragraph_indent_dim }
    \prop_gput:NxV \g_ropas_data_prop { #1/#2/align } \l_ropas_align_tl
    \prop_gput:Nxx \g_ropas_data_prop { #1/#2/title-size }
      { \dim_use:N \l_ropas_title_size_dim }
    \prop_gput:NxV \g_ropas_data_prop { #1/#2/title-colour }
      \l_ropas_title_colour_tl
    \prop_gput:Nxx \g_ropas_data_prop { #1/#2/section-title-size }
      { \dim_use:N \l_ropas_section_title_size_dim }
    \prop_gput:NxV \g_ropas_data_prop { #1/#2/section-title-colour }
      \l_ropas_section_title_colour_tl
    \prop_gput:Nxx \g_ropas_data_prop { #1/#2/text-size }
      { \dim_use:N \l_ropas_text_size_dim }
    \prop_gput:NxV \g_ropas_data_prop { #1/#2/text-colour }
      \l_ropas_text_colour_tl
  }

\cs_new_protected:Npn \ropas_validate_ratios:
  {
    \str_if_eq:VnT \l_ropas_row_ratio_tl {default}
      {\bool_set_false:N \l_ropas_row_ratio_given_bool}
    \str_if_eq:VnT \l_ropas_col_ratio_tl {default}
      {\bool_set_false:N \l_ropas_col_ratio_given_bool}
    \bool_if:NF \l_ropas_row_ratio_given_bool
      {
        \tl_clear:N \l_ropas_row_ratio_tl
        \int_step_inline:nn { \l_ropas_rows_int }
          {
            \tl_if_empty:NF \l_ropas_row_ratio_tl
              { \tl_put_right:Nn \l_ropas_row_ratio_tl { , } }
            \tl_put_right:Nn \l_ropas_row_ratio_tl { auto }
          }
      }
    \bool_if:NF \l_ropas_col_ratio_given_bool
      {
        \tl_clear:N \l_ropas_col_ratio_tl
        \int_step_inline:nn { \l_ropas_cols_int }
          {
            \tl_if_empty:NF \l_ropas_col_ratio_tl
              { \tl_put_right:Nn \l_ropas_col_ratio_tl { , } }
            \tl_put_right:Nn \l_ropas_col_ratio_tl { 1 }
          }
      }
    \clist_set:NV \l_tmpa_clist \l_ropas_row_ratio_tl
    \int_compare:nNnF { \clist_count:N \l_tmpa_clist }
      = { \l_ropas_rows_int }
      { \ropas_class_error:nn { row-ratio~count~does~not~match~row-count }
          { Supply~exactly~one~row-ratio~value~per~row. } }
    \clist_map_inline:Nn \l_tmpa_clist
      {
        \tl_set:Nx \l_tmpa_tl { \tl_trim_spaces:n {##1} }
        \str_if_eq:VnF \l_tmpa_tl { auto }
          {
            \str_if_eq:VnF \l_tmpa_tl { min }
              {
                \regex_match:nVTF
                  { \A \+? (?: [0-9]+ (?: \. [0-9]* )? | \. [0-9]+ ) \Z }
                  \l_tmpa_tl
                  {
                    \fp_compare:nNnF { \l_tmpa_tl } > { 0 }
                      { \ropas_class_error:nn
                          { row-ratio~values~must~be~positive }
                          { Use~a~positive~number,~auto,~or~min. } }
                  }
                  { \ropas_class_error:nn { Invalid~row-ratio~value~'##1' }
                      { Use~a~positive~number,~auto,~or~min. } }
              }
          }
      }
    \clist_set:NV \l_tmpa_clist \l_ropas_col_ratio_tl
    \int_compare:nNnF { \clist_count:N \l_tmpa_clist }
      = { \l_ropas_cols_int }
      { \ropas_class_error:nn { col-ratio~count~does~not~match~col-count }
          { Supply~exactly~one~col-ratio~value~per~column. } }
    \clist_map_inline:Nn \l_tmpa_clist
      {
        \tl_set:Nx \l_tmpa_tl { \tl_trim_spaces:n {##1} }
        \regex_match:nVTF
          { \A \+? (?: [0-9]+ (?: \. [0-9]* )? | \. [0-9]+ ) \Z }
          \l_tmpa_tl
          {
            \fp_compare:nNnF { \l_tmpa_tl } > { 0 }
              { \ropas_class_error:nn { col-ratio~values~must~be~positive }
                  { Use~a~positive~number. } }
          }
          { \ropas_class_error:nn { Invalid~col-ratio~value~'##1' }
              { col-ratio~accepts~positive~numbers~only. } }
      }
  }

\cs_new_protected:Npn \ropas_store_grid:n #1
  {
    \prop_gput:Nnx \g_ropas_data_prop { grid/#1/rows }
      { \int_use:N \l_ropas_rows_int }
    \prop_gput:NnV \g_ropas_data_prop { grid/#1/row-ratio }
      \l_ropas_row_ratio_tl
    \prop_gput:Nnx \g_ropas_data_prop { grid/#1/cols }
      { \int_use:N \l_ropas_cols_int }
    \prop_gput:NnV \g_ropas_data_prop { grid/#1/col-ratio }
      \l_ropas_col_ratio_tl
    \prop_gput:Nnx \g_ropas_data_prop { grid/#1/gap }
      { \dim_use:N \l_ropas_gap_dim }
    \prop_gput:Nnx \g_ropas_data_prop { grid/#1/line-width }
      { \dim_use:N \l_ropas_line_width_dim }
    \prop_gput:NnV \g_ropas_data_prop { grid/#1/line-colour }
      \l_ropas_line_colour_tl
    \prop_gput:Nnn \g_ropas_data_prop { grid/#1/children } { }
    \ropas_store_style:nn { grid } {#1}
  }

\cs_new_protected:Npn \ropas_grid_initialize:nnN #1#2#3
  {
    \group_begin:
      \int_gincr:N \g_ropas_grid_id_int
      \tl_set:Nx \l_ropas_new_grid_tl { \int_use:N \g_ropas_grid_id_int }
      \int_set:Nn \l_ropas_rows_int { 1 }
      \int_set:Nn \l_ropas_cols_int { 1 }
      \tl_clear:N \l_ropas_row_ratio_tl
      \tl_clear:N \l_ropas_col_ratio_tl
      \bool_set_false:N \l_ropas_row_ratio_given_bool
      \bool_set_false:N \l_ropas_col_ratio_given_bool
      \int_compare:nNnTF {#1} = {0}
        { \ropas_load_style_from_globals: }
        { \ropas_load_style_from_grid:n {#1} }
      \dim_zero:N \l_ropas_line_width_dim
      \tl_set:Nn \l_ropas_line_colour_tl { black }
      \ropas_keys_set_last:nn { ropas-poster / grid } {#2}
      \ropas_validate_ratios:
      \exp_args:NV \ropas_store_grid:n \l_ropas_new_grid_tl
      \box_new:c { g_ropas_grid_\l_ropas_new_grid_tl _render_box }
      \box_new:c { g_ropas_grid_\l_ropas_new_grid_tl _registration_box }
      \tl_gset_eq:NN \g_ropas_return_grid_tl \l_ropas_new_grid_tl
    \group_end:
    \tl_set_eq:NN #3 \g_ropas_return_grid_tl
  }

\int_new:N \l_ropas_row_start_int
\int_new:N \l_ropas_row_end_int
\int_new:N \l_ropas_col_start_int
\int_new:N \l_ropas_col_end_int

\cs_new_protected:Npn \ropas_parse_span:nnNN #1#2#3#4
  {
    \seq_set_split:Nnn \l_tmpa_seq { - } {#1}
    \int_compare:nNnTF { \seq_count:N \l_tmpa_seq } = {1}
      {
        \regex_match:nnTF { \A \s* [0-9]+ \s* \Z } {#1}
          {
            \int_set:Nn #3 {#1}
            \int_set_eq:NN #4 #3
            \int_compare:nNnT {#3} < {1}
              {
                \ropas_class_error:nn { Invalid~#2~span~'#1' }
                  { Span~positions~must~be~positive~integers. }
                \int_set:Nn #3 {1}
                \int_set:Nn #4 {1}
              }
          }
          {
            \ropas_class_error:nn { Invalid~#2~span~'#1' }
              { Use~one~integer~or~two~integers~joined~by~a~hyphen. }
            \int_set:Nn #3 {1} \int_set:Nn #4 {1}
          }
      }
      {
        \int_compare:nNnTF { \seq_count:N \l_tmpa_seq } = {2}
          {
            \tl_set:Nx \l_tmpa_tl
              { \tl_trim_spaces:e { \seq_item:Nn \l_tmpa_seq {1} } }
            \tl_set:Nx \l_tmpb_tl
              { \tl_trim_spaces:e { \seq_item:Nn \l_tmpa_seq {2} } }
            \regex_match:nVTF { \A [0-9]+ \Z } \l_tmpa_tl
              { }
              { \tl_set:Nn \l_tmpa_tl {0} }
            \regex_match:nVTF { \A [0-9]+ \Z } \l_tmpb_tl
              { }
              { \tl_set:Nn \l_tmpb_tl {0} }
            \int_set:Nn #3 { \l_tmpa_tl }
            \int_set:Nn #4 { \l_tmpb_tl }
            \int_compare:nNnT {#3} = {0}
              { \ropas_class_error:nn { Invalid~#2~span~'#1' }
                  { Span~positions~must~be~positive~integers. } }
            \int_compare:nNnT {#4} < {#3}
              { \ropas_class_error:nn { Reversed~#2~span~'#1' }
                  { The~right-hand~position~must~not~be~smaller. } }
          }
          {
            \ropas_class_error:nn { Invalid~#2~span~'#1' }
              { Use~one~integer~or~two~integers~joined~by~a~hyphen. }
            \int_set:Nn #3 {1} \int_set:Nn #4 {1}
          }
      }
  }

\cs_new_protected:Npn \ropas_append_child:nn #1#2
  {
    \prop_get:NxN \g_ropas_data_prop { grid/#1/children } \l_tmpa_tl
    \tl_if_blank:VTF \l_tmpa_tl
      { \prop_gput:Nxn \g_ropas_data_prop { grid/#1/children } {#2} }
      { \prop_gput:Nxx \g_ropas_data_prop { grid/#1/children }
          { \l_tmpa_tl , #2 } }
  }

\cs_new_protected:Npn \ropas_validate_and_mark_position:nnnnn #1#2#3#4#5
  {
    \prop_get:NxN \g_ropas_data_prop { grid/#1/rows } \l_tmpa_tl
    \int_compare:nNnT {#3} > { \l_tmpa_tl }
      { \ropas_class_error:nn { Row~span~is~outside~its~parent~grid }
          { Use~row~positions~between~1~and~\l_tmpa_tl. } }
    \prop_get:NxN \g_ropas_data_prop { grid/#1/cols } \l_tmpa_tl
    \int_compare:nNnT {#5} > { \l_tmpa_tl }
      { \ropas_class_error:nn { Column~span~is~outside~its~parent~grid }
          { Use~column~positions~between~1~and~\l_tmpa_tl. } }
    \int_step_inline:nnn {#2} {#3}
      {
        \int_step_inline:nnn {#4} {#5}
          {
            \prop_if_in:NxTF \g_ropas_data_prop
              { occupied/#1/##1/####1 }
              { \ropas_class_error:nn
                  { Grid~items~overlap~at~row~##1,~column~####1 }
                  { Change~the~row-span~or~col-span~of~one~item. } }
              { \prop_gput:Nxn \g_ropas_data_prop
                  { occupied/#1/##1/####1 } { 1 } }
          }
      }
  }

\cs_new_protected:Npn \ropas_store_child_position:n #1
  {
    \prop_gput:Nnx \g_ropas_data_prop { child/#1/row-start }
      { \int_use:N \l_ropas_row_start_int }
    \prop_gput:Nnx \g_ropas_data_prop { child/#1/row-end }
      { \int_use:N \l_ropas_row_end_int }
    \prop_gput:Nnx \g_ropas_data_prop { child/#1/col-start }
      { \int_use:N \l_ropas_col_start_int }
    \prop_gput:Nnx \g_ropas_data_prop { child/#1/col-end }
      { \int_use:N \l_ropas_col_end_int }
    \prop_gput:Nnx \g_ropas_data_prop { child/#1/parent }
      { \int_use:N \l_ropas_current_grid_int }
  }

\cs_new_protected:Npn \ropas_register_block:nnnn #1#2#3#4
  {
    \ropas_parse_span:nnNN {#1} { row }
      \l_ropas_row_start_int \l_ropas_row_end_int
    \ropas_parse_span:nnNN {#2} { column }
      \l_ropas_col_start_int \l_ropas_col_end_int
    \ropas_validate_and_mark_position:nnnnn
      { \int_use:N \l_ropas_current_grid_int }
      { \l_ropas_row_start_int } { \l_ropas_row_end_int }
      { \l_ropas_col_start_int } { \l_ropas_col_end_int }
    \int_gincr:N \g_ropas_child_id_int
    \tl_set:Nx \l_ropas_child_tl { \int_use:N \g_ropas_child_id_int }
    \int_step_inline:nnn { \l_ropas_row_start_int } { \l_ropas_row_end_int }
      {
        \int_step_inline:nnn { \l_ropas_col_start_int } { \l_ropas_col_end_int }
          { \prop_gput:NxV \g_ropas_data_prop
              { occupied/\int_use:N\l_ropas_current_grid_int/##1/####1 }
              \l_ropas_child_tl }
      }
    \exp_args:Nxx \ropas_append_child:nn
      { \int_use:N \l_ropas_current_grid_int } { \l_ropas_child_tl }
    \exp_args:NV \ropas_store_child_position:n \l_ropas_child_tl
    \prop_gput:Nxx \g_ropas_data_prop { child/\l_ropas_child_tl/type } { block }
    \prop_gput:Nxn \g_ropas_data_prop { child/\l_ropas_child_tl/body } {#4}
    \ropas_load_style_from_grid:n { \int_use:N \l_ropas_current_grid_int }
    \ropas_keys_set_last:nn { ropas-poster / block } {#3}
    \exp_args:NnV \ropas_store_style:nn { child } \l_ropas_child_tl
    \prop_gput:NxV \g_ropas_data_prop { child/\l_ropas_child_tl/align }
      \l_ropas_align_tl
    \bool_if:NTF \l_ropas_capture_title_first_bool
      { \prop_gput:Nxn \g_ropas_data_prop
          { child/\l_ropas_child_tl/title-first } { true } }
      { \prop_gput:Nxn \g_ropas_data_prop
          { child/\l_ropas_child_tl/title-first } { false } }
    \box_new:c { g_ropas_child_\l_ropas_child_tl _content_box }
    \box_new:c { g_ropas_child_\l_ropas_child_tl _title_box }
    \box_new:c { g_ropas_child_\l_ropas_child_tl _render_box }
    \box_new:c { g_ropas_child_\l_ropas_child_tl _footnote_box }
    \box_new:c { g_ropas_child_\l_ropas_child_tl _top_float_box }
    \box_new:c { g_ropas_child_\l_ropas_child_tl _bottom_float_box }
    \seq_new:c { g_ropas_child_\l_ropas_child_tl _notes_seq }
  }

\cs_new_protected:Npn \ropas_register_container_title:n #1
  {
    \prop_get:NxN \g_ropas_data_prop
      { child/\l_ropas_container_child_tl/title-count } \l_tmpa_tl
    \int_compare:nNnTF {\l_tmpa_tl} = {0}
      {
        \prop_get:NxN \g_ropas_data_prop
          { child/\l_ropas_container_child_tl/title-first } \l_tmpa_tl
        \str_if_eq:VnF \l_tmpa_tl { true }
          {
            \ropas_class_error:nn
              { blocktitle~is~not~the~first~command~in~its~posterblock }
              { Move~blocktitle~before~the~nested~postergrid. }
          }
        \prop_gput:Nxn \g_ropas_data_prop
          { child/\l_ropas_container_child_tl/container-title } {#1}
        \prop_gput:Nxn \g_ropas_data_prop
          { child/\l_ropas_container_child_tl/title-count } { 1 }
      }
      {
        \ropas_class_error:nn
          { A~posterblock~contains~more~than~one~blocktitle }
          { Keep~at~most~one~blocktitle~in~each~posterblock. }
      }
    \ignorespaces
  }

\cs_new_protected:Npn \ropas_register_grid_block:nnnnn #1#2#3#4#5
  {
    \str_if_eq:nnTF {#5}{true}
      {
        \tl_if_blank:nF {#3}
          {
            \ropas_class_error:nn
              { A~structural~posterblock*~does~not~accept~block~options }
              { Put~layout~options~on~its~nested~postergrid. }
          }
        \ropas_register_block:nnnn {#1}{#2}{}{ }
      }
      { \ropas_register_block:nnnn {#1}{#2}{#3}{ } }
    \tl_set_eq:NN \l_ropas_container_child_tl \l_ropas_child_tl
    \str_if_eq:nnTF {#5}{true}
      { \prop_gput:Nxn \g_ropas_data_prop
          { child/\l_ropas_container_child_tl/type } { subgrid } }
      { \prop_gput:Nxn \g_ropas_data_prop
          { child/\l_ropas_container_child_tl/type } { grid-block } }
    \prop_gput:Nxn \g_ropas_data_prop
      { child/\l_ropas_container_child_tl/has-grid } { false }
    \prop_gput:Nxn \g_ropas_data_prop
      { child/\l_ropas_container_child_tl/title-count } { 0 }
    \prop_gput:Nxn \g_ropas_data_prop
      { child/\l_ropas_container_child_tl/container-title } { }
    \group_begin:
      \tl_set:Nn \l_ropas_context_tl { block-registration }
      \bool_set_false:N \l_ropas_register_bool
      \str_if_eq:nnTF {#5}{true}
        {
          \cs_set_protected:Npn \blocktitle ##1
            {
              \ropas_class_error:nn
                { blocktitle~is~not~allowed~in~posterblock* }
                { Use~an~ordinary~posterblock~when~a~blocktitle~is~needed. }
            }
        }
        { \cs_set_protected:Npn \blocktitle ##1
            { \ropas_register_container_title:n {##1} } }
      \vbox_set:Nn \l_tmpa_box
        {
          \hsize=1pt
          \linewidth=\hsize
          \parindent=0pt
          \everypar { }
          \hfuzz=\maxdimen
          \hbadness=10000
          \vfuzz=\maxdimen
          \vbadness=10000
          #4
        }
      \dim_compare:nNnT
        { \box_ht:N \l_tmpa_box + \box_dp:N \l_tmpa_box
          + \box_wd:N \l_tmpa_box } > {0pt}
        {
          \ropas_class_error:nn
            { A~grid~posterblock~contains~ordinary~content }
            { Keep~only~an~optional~blocktitle~and~one~direct~postergrid. }
        }
    \group_end:
    \prop_get:NxN \g_ropas_data_prop
      { child/\l_ropas_container_child_tl/has-grid } \l_tmpa_tl
    \str_if_eq:VnF \l_tmpa_tl { true }
      {
        \ropas_class_error:nn
          { A~grid~posterblock~does~not~contain~a~postergrid }
          { Put~exactly~one~direct~postergrid~inside~the~posterblock. }
      }
  }

% --------------------------------------------------------------------------
% Cell typesetting and minimum-size measurement
% --------------------------------------------------------------------------

\box_new:N \l_ropas_source_box
\box_new:N \l_ropas_split_box
\box_new:N \l_ropas_render_box
\box_new:N \l_ropas_body_render_box
\bool_new:N \g_ropas_horizontal_overflow_bool
\bool_new:N \l_ropas_cell_title_seen_bool
\bool_new:N \l_ropas_first_body_paragraph_bool
\dim_new:N \l_ropas_cell_inner_width_dim
\dim_new:N \g_ropas_return_dim
\seq_new:N \l_ropas_row_dims_seq
\seq_new:N \l_ropas_row_types_seq
\fp_new:N \l_ropas_ratio_sum_fp
\skip_new:N \l_ropas_list_sep_skip
\skip_new:N \l_ropas_saved_splittopskip_skip
\int_new:N \l_ropas_list_depth_int

\cs_new_protected:Npn \ropas_load_style_from_child:n #1
  { \ropas_load_style:nn { child } {#1} }

% Begin and end a block whose requested separation from adjacent material is
% the same as the complete inter-paragraph separation.  \addvspace makes this
% a minimum: an adjacent object may request a larger separation, but two
% requests are never added together.  The first body object needs no leading
% skip because a cell title, when present, already owns the title/body gap.
\cs_new_protected:Npn \ropas_interblock_begin:
  {
    % TeX appends \parskip while ending the preceding paragraph, so suppress
    % it before \par as well as before starting this block's paragraph.
    \parskip=0pt
    \par
    \bool_if:NF \l_ropas_first_body_paragraph_bool
      {
        \addvspace { \l_ropas_paragraph_leading_dim }
      }
    % The table or heading is itself put in a paragraph.  Suppress that
    % paragraph's \parskip so it cannot be added to the block separation.
    \parskip=0pt
    % A table/minipage and a heading are line boxes.  TeX would otherwise add
    % automatic interline glue on top of the explicit block separation.
    \nointerlineskip
  }

\cs_new_protected:Npn \ropas_interblock_end:
  {
    \parskip=0pt
    \par
    \addvspace { \l_ropas_paragraph_leading_dim }
    % The next ordinary paragraph must use the already present block skip.
    % Its terminating \par restores the normal paragraph-leading value.
    \parskip=0pt
    \nointerlineskip
  }

\cs_new_protected:Npn \ropas_heading:nnn #1#2#3
  {
    \ropas_interblock_begin:
    \noindent
    { \sffamily\bfseries
      \ropas_set_size_base:nn
        {#1}{ \dim_eval:n { #1 + \l_ropas_text_leading_dim } }
      \fontsize{#1}{\dim_eval:n { #1 + \l_ropas_text_leading_dim }}
      \selectfont\color{#2}#3\par }
    \nobreak
    \ropas_interblock_end:
  }

\cs_new_protected:Npn \ropas_typeset_cell_title:nnn #1#2#3
  {
    \bool_if:NT \l_ropas_cell_title_seen_bool
      {
        \ropas_class_error:nn
          { A~posterblock~contains~more~than~one~blocktitle }
          { Keep~at~most~one~blocktitle~in~each~posterblock. }
      }
    \prop_get:NxN \g_ropas_data_prop { child/#1/title-first } \l_tmpa_tl
    \str_if_eq:VnF \l_tmpa_tl { true }
      {
        \ropas_class_error:nn
          { blocktitle~is~not~the~first~command~in~its~posterblock }
          { Move~blocktitle~before~all~other~block~content. }
      }
    \bool_set_true:N \l_ropas_cell_title_seen_bool
    \vbox_gset:cn { g_ropas_child_#1_title_box }
      {
        \hsize=#2
        \linewidth=\hsize
        \columnwidth=\hsize
        \textwidth=\hsize
        \parindent=0pt
        \parskip=0pt
        \lineskip=1pt
        \lineskiplimit=0pt
        \everypar { }
        \hfuzz=\maxdimen
        \hbadness=10000
        \cs_set_eq:NN \par \ropas_saved_par:
        \sffamily\bfseries
        \ropas_set_size_base:nn
          { \l_ropas_title_size_dim }
          { \dim_eval:n
              { \l_ropas_title_size_dim + \l_ropas_text_leading_dim } }
        \fontsize{\l_ropas_title_size_dim}
          { \dim_eval:n
              { \l_ropas_title_size_dim + \l_ropas_text_leading_dim } }
        \selectfont
        \color{\l_ropas_title_colour_tl}
        \noindent #3\par
        \int_compare:nNnT { \tex_badness:D } > { 10000 }
          { \bool_gset_true:N \g_ropas_horizontal_overflow_bool }
      }
    \prop_gput:Nnn \g_ropas_data_prop { child/#1/title-present } { true }
    \prop_gput:Nxx \g_ropas_data_prop { child/#1/title-height }
      {
        \dim_eval:n
          {
            \box_ht:c { g_ropas_child_#1_title_box }
            + \box_dp:c { g_ropas_child_#1_title_box }
          }
      }
    \prop_gput:Nxx \g_ropas_data_prop { child/#1/title-width }
      { \dim_eval:n {#2} }
    \ignorespaces
  }

\cs_new_protected:Npn \ropas_install_cell_commands:nn #1#2
  {
    \cs_set_protected:Npn \blocktitle ##1
      { \ropas_typeset_cell_title:nnn {#1}{#2}{##1} }
    \DeclareDocumentCommand \sectiontitle { m }
      { \ropas_heading:nnn { \l_ropas_section_title_size_dim }
          { \l_ropas_section_title_colour_tl } {##1} }
  }

\int_new:N \g_ropas_float_id_int
\tl_new:N \l_ropas_float_id_tl
\tl_new:N \l_ropas_float_placement_tl
\seq_new:N \g_ropas_float_top_seq
\seq_new:N \g_ropas_float_bottom_seq

\cs_new_protected:Npn \ropas_float_capture_begin:nn #1#2
  {
    \par
    \tl_set:Nn \l_ropas_float_placement_tl {inline}
    \str_if_eq:nnF {#2}{H}
      {
        \regex_match:nnTF {\A [htb!]+ \Z} {#2}
          {
            \str_if_eq:nnT {#2}{h}
              {\ClassWarning{ropas-poster}
                {Float~placement~h~changed~to~ht}}
            \tl_if_in:nnTF {#2}{h}
              { }
              {\tl_if_in:nnTF {#2}{t}
                {\tl_set:Nn \l_ropas_float_placement_tl {top}}
                {\tl_if_in:nnTF {#2}{b}
                  {\tl_set:Nn \l_ropas_float_placement_tl {bottom}}
                  {\ropas_class_error:nn
                    { Invalid~float~placement~'#2' }
                    { Use~h,~t,~b,~!,~or~H~as~documented. }}}}
          }
          {\ropas_class_error:nn { Invalid~float~placement~'#2' }
            { Use~h,~t,~b,~!,~or~H~as~documented. }}
      }
    \int_gincr:N \g_ropas_float_id_int
    \tl_set:Nx \l_ropas_float_id_tl
      {\int_use:N \g_ropas_float_id_int}
    \box_new:c {g_ropas_float_\l_ropas_float_id_tl _box}
    \dim_set:Nn \l_tmpa_dim {\linewidth}
    \bool_if:NT \l_ropas_float_star_bool
      {\dim_set_eq:NN \l_tmpa_dim \l_ropas_cell_inner_width_dim}
    \vbox_gset:cw {g_ropas_float_\l_ropas_float_id_tl _box}
      \hsize=\l_tmpa_dim
      \linewidth=\hsize\columnwidth=\hsize\textwidth=\hsize
      \parindent=0pt\parskip=0pt
      % amsart (and hence acmart) centres float contents by default.
      \centering
      \cs_set:Npn \@captype {#1}
      \captionsetup{font=ropas-cell,singlelinecheck=true}
  }

\cs_new_protected:Npn \ropas_float_capture_end:
  {
    \par
    \vbox_gset_end:
    \str_case:Vn \l_ropas_float_placement_tl
      {
        {inline}
          {\ropas_interblock_begin:
           \noindent\box_use:c
             {g_ropas_float_\l_ropas_float_id_tl _box}
           \ropas_interblock_end:}
        {top}
          {\seq_gput_right:NV \g_ropas_float_top_seq
            \l_ropas_float_id_tl}
        {bottom}
          {\seq_gput_right:NV \g_ropas_float_bottom_seq
            \l_ropas_float_id_tl}
      }
  }

\cs_new_protected:Npn \ropas_build_float_queue_box:nnn #1#2#3
  {
    \vbox_gset:cn {g_ropas_child_#1_#2_float_box}
      {
        \hsize=#3\parindent=0pt\parskip=0pt\offinterlineskip
        \exp_args:Nc \seq_map_indexed_inline:Nn
          {g_ropas_float_#2_seq}
          {
            \int_compare:nNnT {##1} > {1}
              {\vskip \l_ropas_paragraph_leading_dim}
            \hbox to #3
              {\box_use:c {g_ropas_float_##2_box}\hfil}
          }
      }
  }

\cs_new_protected:Npn \ropas_install_block_floats:
  {
    \cs_set_protected:Npn \@xfloat ##1[##2]
      {\ropas_float_capture_begin:nn {##1}{##2}}
    \cs_set_protected:Npn \@float ##1 {\@xfloat{##1}[tb]}
    \cs_set_protected:Npn \@dblfloat ##1 {\@xfloat{##1}[tb]}
    \cs_set_protected:Npn \end@float {\ropas_float_capture_end:}
    \cs_set_eq:NN \end@dblfloat \end@float
  }

% Match the list design of the repository's acmart.cls in acmsmall mode.
% acmsmall uses a 10pt body font; every fixed list measurement is therefore
% expressed as the corresponding fraction of the active poster body size.
\cs_new_protected:Npn \ropas_install_acmsmall_lists:
  {
    \dim_set:Nn \labelsep { .4 \l_ropas_text_size_dim }
    \dim_set:Nn \leftmargini { 2.45 \l_ropas_text_size_dim }
    \dim_set:Nn \leftmarginii { .85 \l_ropas_text_size_dim }
    \dim_set_eq:NN \leftmarginiii \leftmarginii
    \dim_set_eq:NN \leftmarginiv \leftmarginiii
    \dim_set_eq:NN \leftmarginv \leftmarginiv
    \dim_set_eq:NN \leftmarginvi \leftmarginv
    \skip_set:Nn \l_ropas_list_sep_skip
      {
        .21 \l_ropas_text_size_dim
        plus .21 \l_ropas_text_size_dim
      }
    \int_zero:N \l_ropas_list_depth_int

    \cs_set_protected:Npn \ropas_after_list:
      {
        % An outer list's topsep owns the list/text boundary.  Start the first
        % following paragraph without an additional paragraph-leading value;
        % its terminating \par enables normal spacing for the next paragraph.
        \parskip=0pt
        % LaTeX's \@endparenv replaces \par while leaving a list.  Restore the
        % cell wrapper so later blank lines can enable paragraph-leading.
        \cs_set_eq:NN \par \ropas_cell_par:
      }

    \cs_set:Npn \theenumi { \@arabic \c@enumi }
    \cs_set:Npn \labelenumi { (\theenumi) }
    \cs_set:Npn \theenumii { \@alph \c@enumii }
    \cs_set:Npn \labelenumii { (\theenumii) }
    \cs_set:Npn \p@enumii { \theenumi }
    \cs_set:Npn \theenumiii { \@roman \c@enumiii }
    \cs_set:Npn \labelenumiii { (\theenumiii) }
    \cs_set:Npn \p@enumiii { \theenumi (\theenumii) }
    \cs_set:Npn \theenumiv { \@Alph \c@enumiv }
    \cs_set:Npn \labelenumiv { (\theenumiv) }
    \cs_set:Npn \p@enumiv { \p@enumiii \theenumiii }
    \cs_set:Npn \labelitemi { $\m@th\bullet$ }
    \cs_set:Npn \labelitemii { \bfseries -- }
    \cs_set:Npn \labelitemiii { $\m@th\ast$ }
    \cs_set:Npn \labelitemiv { $\m@th\cdot$ }

    \cs_set_protected:Npn \@listI
      {
        \leftmargin \leftmargini
        \labelwidth \leftmargini
        \advance \labelwidth -\labelsep
        \listparindent \c_zero_dim
        % LaTeX adds \parskip to \topsep at a paragraph/list boundary.  The
        % poster paragraph spacing and acmsmall list spacing are competing
        % requirements, so retain their maximum instead of their sum.  At the
        % top of a cell \parskip is zero and the complete acmsmall topsep is
        % consequently preserved.
        \skip_set_eq:NN \topsep \l_ropas_list_sep_skip
        \dim_compare:nNnTF { \parskip } < { \topsep }
          { \skip_sub:Nn \topsep { \parskip } }
          { \skip_zero:N \topsep }
        \parsep \c_zero_skip
        \partopsep \c_zero_skip
        \itemsep \c_zero_skip
      }
    \cs_set_eq:NN \@listi \@listI
    \cs_set_protected:Npn \@listii
      {
        \leftmargin \leftmarginii
        \labelwidth \leftmarginii
        \advance \labelwidth -\labelsep
        \listparindent \c_zero_dim
        \topsep \c_zero_skip
        \parsep \c_zero_skip
        \partopsep \c_zero_skip
        \itemsep \c_zero_skip
      }
    \cs_set_protected:Npn \@listiii
      {
        \leftmargin \leftmarginiii
        \labelwidth \leftmarginiii
        \advance \labelwidth -\labelsep
        \listparindent \c_zero_dim
        \topsep \c_zero_skip
        \parsep \c_zero_skip
        \partopsep \c_zero_skip
        \itemsep \c_zero_skip
      }
    \cs_set_protected:Npn \@listiv
      {
        \leftmargin \leftmarginiv
        \labelwidth \leftmarginiv
        \advance \labelwidth -\labelsep
        \listparindent \c_zero_dim
        \topsep \c_zero_skip
        \parsep \c_zero_skip
        \partopsep \c_zero_skip
        \itemsep \c_zero_skip
      }
    \cs_set_protected:Npn \@listv
      {
        \leftmargin \leftmarginv
        \labelwidth \leftmarginv
        \advance \labelwidth -\labelsep
        \listparindent \c_zero_dim
        \topsep \c_zero_skip
        \parsep \c_zero_skip
        \partopsep \c_zero_skip
        \itemsep \c_zero_skip
      }
    \cs_set_protected:Npn \@listvi
      {
        \leftmargin \leftmarginvi
        \labelwidth \leftmarginvi
        \advance \labelwidth -\labelsep
        \listparindent \c_zero_dim
        \topsep \c_zero_skip
        \parsep \c_zero_skip
        \partopsep \c_zero_skip
        \itemsep \c_zero_skip
      }

    \cs_set_protected:Npn \enumerate
      {
        \ifnum \@enumdepth > 3\relax
          \@toodeep
        \else
          % Mark list mode before \list performs acmart/amsart's structural
          % paragraph ending.  It must not enable paragraph-leading; an actual
          % preceding blank line has already done so independently.
          % A paragraph that itself followed a blank line may still carry the
          % old nonzero \parskip.  An immediate paragraph-to-list transition
          % uses acmsmall's topsep instead, so clear that inherited value only
          % while still in horizontal mode.
          \mode_if_horizontal:T { \parskip=0pt }
          \int_incr:N \l_ropas_list_depth_int
          \advance \@enumdepth \@ne
          \edef \@enumctr { enum\romannumeral\the\@enumdepth }
          \list { \csname label\@enumctr\endcsname }
            {
              \usecounter {\@enumctr}
              \cs_set:Npn \makelabel ####1
                { \hss\llap{\upshape ####1} }
            }
        \fi
      }
    \cs_set_protected:Npn \endenumerate
      {
        \endlist
        \int_decr:N \l_ropas_list_depth_int
        \aftergroup\ropas_after_list:
      }
    \cs_set_protected:Npn \itemize
      {
        \ifnum \@itemdepth > 3\relax
          \@toodeep
        \else
          \mode_if_horizontal:T { \parskip=0pt }
          \int_incr:N \l_ropas_list_depth_int
          \advance \@itemdepth \@ne
          \edef \@itemitem { labelitem\romannumeral\the\@itemdepth }
          \list { \csname\@itemitem\endcsname }
            {
              \cs_set:Npn \makelabel ####1
                { \hss\llap{\upshape ####1} }
            }
        \fi
      }
    \cs_set_protected:Npn \enditemize
      {
        \endlist
        \int_decr:N \l_ropas_list_depth_int
        \aftergroup\ropas_after_list:
      }
  }

% Packages such as natbib inspect \@listi while loading in the preamble.
% Publish the class's list defaults there as well as inside each block.
\ropas_load_style_from_globals:
\ropas_install_acmsmall_lists:

\cs_new_protected:Npn \ropas_cell_typeset:nn #1#2
  {
    \ropas_load_style_from_child:n {#1}
    \ropas_theorem_style_enter:n {\l_ropas_text_size_dim}
    \tl_gset:Nn \g_ropas_current_footnote_owner_tl {#1}
    \exp_args:Nc \seq_gclear:N {g_ropas_child_#1_notes_seq}
    \dim_set:Nn \l_ropas_cell_inner_width_dim {#2}
    \dim_set:Nn \l_tmpa_dim
      {
        ( \l_ropas_cell_inner_width_dim
          - \int_eval:n { \l_ropas_column_num_int - 1 }
          \l_ropas_column_gap_dim ) / \l_ropas_column_num_int
      }
    \dim_compare:nNnF { \l_tmpa_dim } > { 0pt }
      {
        \ropas_class_error:nn
          { Block~columns~have~no~positive~text~width }
          { Reduce~column-count,~column-sep,~or~block~margin. }
        \dim_set:Nn \l_tmpa_dim { 1pt }
      }
    \dim_compare:nNnT {\l_tmpa_dim} < {\l_ropas_text_size_dim}
      { \ropas_class_error:nn
          { Block~text~column~is~narrower~than~text-size }
          { Reduce~the~font~size~or~the~number~and~spacing~of~columns. } }
    \prop_gput:Nxx \g_ropas_data_prop { child/#1/column-width }
      { \dim_use:N \l_tmpa_dim }
    \bool_gset_false:N \g_ropas_horizontal_overflow_bool
    \bool_set_false:N \l_ropas_cell_title_seen_bool
    \bool_set_true:N \l_ropas_first_body_paragraph_bool
    \box_gclear:c { g_ropas_child_#1_title_box }
    \seq_gclear:N \g_ropas_float_top_seq
    \seq_gclear:N \g_ropas_float_bottom_seq
    \prop_gput:Nnn \g_ropas_data_prop { child/#1/title-present } { false }
    \prop_gput:Nnn \g_ropas_data_prop { child/#1/title-height } { 0pt }
    \prop_gput:Nnn \g_ropas_data_prop { child/#1/title-width } { 0pt }
    \vbox_gset:cn { g_ropas_child_#1_content_box }
      {
        \hsize=\l_tmpa_dim
        \linewidth=\hsize
        \columnwidth=\hsize
        \textwidth=\hsize
        \parindent=\l_ropas_paragraph_indent_dim
        % Explicitly restore ordinary full justification.  This prevents
        % surrounding declarations or packages from leaking ragged settings
        % into cell body paragraphs.
        \leftskip=0pt
        \rightskip=0pt
        \parfillskip=0pt plus 1fil
        \spaceskip=0pt
        \xspaceskip=0pt
        % The first paragraph starts at the top of the body area.  TeX inserts
        % \parskip when the following paragraph begins, so enable it only
        % after this first paragraph has ended.
        \parskip=0pt
        \lineskip=1pt
        \lineskiplimit=0pt
        \everypar { }
        \hfuzz=\maxdimen
        \hbadness=10000
        \ropas_set_size_base:nn
          { \l_ropas_text_size_dim }
          { \dim_eval:n
              { \l_ropas_text_size_dim + \l_ropas_text_leading_dim } }
        \sffamily
        \fontsize{\l_ropas_text_size_dim}
          { \dim_eval:n { \l_ropas_text_size_dim + \l_ropas_text_leading_dim } }
        \selectfont
        % acmsmall uses 5pt of tabular padding on each side at a 10pt
        % body size.  Scale that padding with this block's text-size.
        \tabcolsep=.5\l_ropas_text_size_dim
        % Poster columns can be narrow relative to their type size.  LaTeX's
        % ordinary paragraph tolerance may then choose overfull lines even
        % though every line box has the requested width, which leaves a visibly
        % uneven right edge.  Use LaTeX's standard sloppy line-breaking values
        % while retaining the explicit full-justification skips above.
        \tolerance=9999
        \emergencystretch=3em
        \color{\l_ropas_text_colour_tl}
        \captionsetup{font=ropas-cell,singlelinecheck=true}
        \ropas_install_acmsmall_lists:
        \cs_set_eq:NN \ropas_saved_par: \par
        \cs_set_protected:Npn \ropas_cell_par:
          {
            \mode_if_horizontal:T
              {
                \bool_if:NT \l_ropas_first_body_paragraph_bool
                  {
                    \bool_set_false:N \l_ropas_first_body_paragraph_bool
                  }
                % Only a real paragraph ending may enable spacing before the
                % next paragraph.  A blank \par in vertical mode (notably the
                % empty line after a float) must leave the float's one-shot
                % suppression intact.
                \int_compare:nNnT { \l_ropas_list_depth_int } = {0}
                  { \parskip=\dim_eval:n
                      { \l_ropas_paragraph_leading_dim
                        - \l_ropas_text_leading_dim } }
              }
            \ropas_saved_par:
            \int_compare:nNnT { \tex_badness:D } > { 10000 }
              { \bool_gset_true:N \g_ropas_horizontal_overflow_bool }
          }
        \cs_set_eq:NN \par \ropas_cell_par:
        \ropas_install_cell_commands:nn
          {#1}{\l_ropas_cell_inner_width_dim}
        \cs_set_protected:Npn \columnbreak
          { \par\penalty -10000\relax }
        \ropas_install_block_floats:
        \tl_set:Nn \l_ropas_context_tl { block }
        \prop_get:NxN \g_ropas_data_prop { child/#1/body } \l_tmpb_tl
        \tl_use:N \l_tmpb_tl
        \par
      }
    \ropas_build_float_queue_box:nnn
      {#1}{top}{\l_ropas_cell_inner_width_dim}
    \ropas_build_float_queue_box:nnn
      {#1}{bottom}{\l_ropas_cell_inner_width_dim}
    \ropas_build_footnotes:nn {#1}{\l_ropas_cell_inner_width_dim}
    \dim_compare:nNnTF
      {
        \box_ht:c { g_ropas_child_#1_content_box }
        + \box_dp:c { g_ropas_child_#1_content_box }
      }
      > { 0pt }
      { \prop_gput:Nnn \g_ropas_data_prop { child/#1/body-present } { true } }
      { \prop_gput:Nnn \g_ropas_data_prop { child/#1/body-present } { false } }
    \bool_if:NTF \g_ropas_horizontal_overflow_bool
      { \prop_gput:Nnn \g_ropas_data_prop { child/#1/h-overflow } { true } }
      { \prop_gput:Nnn \g_ropas_data_prop { child/#1/h-overflow } { false } }
    \ropas_theorem_style_leave:
  }

% TeX packs the result of \vsplit to the requested height before returning it.
% A normal cell column has fixed vertical glue, so an otherwise correct split
% can produce an underfull-vbox diagnostic merely because a legal breakpoint
% lies below that exact height.  Give the temporary split box zero-size
% infinitely stretchable material at its top.  This makes the requested box
% intrinsically packable (badness zero) without changing the natural height,
% the selected breakpoint, or the subsequently repacked column.  A zero
% \splittopskip keeps the invisible marker from moving the real content.
\cs_new_protected:Npn \ropas_vbox_split_flexible:NNn #1#2#3
  {
    \vbox_set:Nn #2
      {
        \hrule height 0pt width 0pt
        \vskip 0pt plus 1fil
        \vbox_unpack_drop:N #2
      }
    \skip_set_eq:NN \l_ropas_saved_splittopskip_skip \tex_splittopskip:D
    \tex_splittopskip:D=0pt\scan_stop:
    \vbox_set_split_to_ht:NNn #1#2 {#3}
    \skip_set_eq:NN \tex_splittopskip:D \l_ropas_saved_splittopskip_skip
  }

\prg_new_protected_conditional:Npnn \ropas_cell_fits_height:nn #1#2 { TF }
  {
    \box_set_eq:Nc \l_ropas_source_box { g_ropas_child_#1_content_box }
    \int_step_inline:nn { \l_ropas_column_num_int - 1 }
      {
        \ropas_vbox_split_flexible:NNn \l_ropas_split_box
          \l_ropas_source_box {#2}
      }
    \dim_compare:nNnTF
      { \box_ht:N \l_ropas_source_box + \box_dp:N \l_ropas_source_box }
      > {#2}
      { \prg_return_false: }
      { \prg_return_true: }
  }

\cs_new_protected:Npn \ropas_cell_content_min_height:nN #1#2
  {
    \dim_set:Nn \l_tmpb_dim
      { \box_ht:c { g_ropas_child_#1_content_box }
        + \box_dp:c { g_ropas_child_#1_content_box } }
    % With one column the natural height is the exact minimum: splitting and
    % binary-searching the same box cannot change it.
    \int_compare:nNnTF { \l_ropas_column_num_int } = { 1 }
      { \dim_set_eq:NN #2 \l_tmpb_dim }
      {
        \dim_zero:N \l_tmpa_dim
        \int_step_inline:nn { 24 }
          {
            \dim_set:Nn \l_ropas_tmpc_dim
              { \l_tmpa_dim + ( \l_tmpb_dim - \l_tmpa_dim ) / 2 }
            \ropas_cell_fits_height:nnTF {#1} { \l_ropas_tmpc_dim }
              { \dim_set_eq:NN \l_tmpb_dim \l_ropas_tmpc_dim }
              { \dim_set_eq:NN \l_tmpa_dim \l_ropas_tmpc_dim }
          }
        \dim_set_eq:NN #2 \l_tmpb_dim
      }
  }

\dim_new:N \l_ropas_sep_left_dim
\dim_new:N \l_ropas_sep_right_dim
\dim_new:N \l_ropas_sep_top_dim
\dim_new:N \l_ropas_sep_bottom_dim
\dim_new:N \l_ropas_sep_half_dim
\cs_new_protected:Npn \ropas_block_side_separations:n #1
  {
    \dim_zero:N \l_ropas_sep_left_dim
    \dim_zero:N \l_ropas_sep_right_dim
    \dim_zero:N \l_ropas_sep_top_dim
    \dim_zero:N \l_ropas_sep_bottom_dim
    \prop_get:NxN \g_ropas_data_prop {child/#1/parent} \l_tmpa_tl
    \prop_get:NxN \g_ropas_data_prop {grid/\l_tmpa_tl/gap} \l_tmpb_tl
    \dim_set:Nn \l_ropas_sep_half_dim {\l_tmpb_tl / 2}
    \prop_get:NxN \g_ropas_data_prop {child/#1/col-start} \l_ropas_tmpc_tl
    \int_compare:nNnT {\l_ropas_tmpc_tl} > {1}
      {\dim_set_eq:NN \l_ropas_sep_left_dim \l_ropas_sep_half_dim}
    \prop_get:NxN \g_ropas_data_prop {child/#1/col-end} \l_ropas_tmpc_tl
    \prop_get:NxN \g_ropas_data_prop {grid/\l_tmpa_tl/cols} \l_ropas_tmpd_tl
    \int_compare:nNnT {\l_ropas_tmpc_tl} < {\l_ropas_tmpd_tl}
      {\dim_set_eq:NN \l_ropas_sep_right_dim \l_ropas_sep_half_dim}
    \prop_get:NxN \g_ropas_data_prop {child/#1/row-start} \l_ropas_tmpc_tl
    \int_compare:nNnT {\l_ropas_tmpc_tl} > {1}
      {\dim_set_eq:NN \l_ropas_sep_top_dim \l_ropas_sep_half_dim}
    \prop_get:NxN \g_ropas_data_prop {child/#1/row-end} \l_ropas_tmpc_tl
    \prop_get:NxN \g_ropas_data_prop {grid/\l_tmpa_tl/rows} \l_ropas_tmpd_tl
    \int_compare:nNnT {\l_ropas_tmpc_tl} < {\l_ropas_tmpd_tl}
      {\dim_set_eq:NN \l_ropas_sep_bottom_dim \l_ropas_sep_half_dim}
  }

\cs_new_protected:Npn \ropas_measure_cell:nn #1#2
  {
    \group_begin:
      \dim_set:Nn \l_ropas_cell_outer_width_dim {#2}
      \ropas_load_style_from_child:n {#1}
      \ropas_block_side_separations:n {#1}
      \dim_set:Nn \l_tmpa_dim
        { \l_ropas_cell_outer_width_dim
          - \l_ropas_sep_left_dim - \l_ropas_sep_right_dim
          - 2 \l_ropas_margin_dim }
      \dim_compare:nNnF { \l_tmpa_dim } > { 0pt }
        {
          \ropas_class_error:nn { Block~has~no~positive~inner~width }
            { Reduce~the~block~separation~or~margin. }
          \dim_set:Nn \l_tmpa_dim { 1pt }
        }
      \ropas_cell_typeset:nn {#1} { \l_tmpa_dim }
      \ropas_cell_content_min_height:nN {#1} \l_ropas_tmpc_dim
      \prop_gput:Nxx \g_ropas_data_prop { child/#1/body-min-height }
        { \dim_use:N \l_ropas_tmpc_dim }
      \dim_set:Nn \l_tmpa_dim
        { \box_ht:c {g_ropas_child_#1_top_float_box}
          + \box_dp:c {g_ropas_child_#1_top_float_box} }
      \dim_set:Nn \l_tmpb_dim
        { \box_ht:c {g_ropas_child_#1_bottom_float_box}
          + \box_dp:c {g_ropas_child_#1_bottom_float_box} }
      \dim_compare:nNnT {\l_tmpa_dim} > {0pt}
        {
          \dim_add:Nn \l_ropas_tmpc_dim {\l_tmpa_dim}
          \dim_compare:nNnT
            {\box_ht:c {g_ropas_child_#1_content_box}} > {0pt}
            {\dim_add:Nn \l_ropas_tmpc_dim {\l_ropas_paragraph_leading_dim}}
        }
      \dim_compare:nNnT {\l_tmpb_dim} > {0pt}
        {
          \dim_add:Nn \l_ropas_tmpc_dim {\l_tmpb_dim}
          \dim_compare:nNnT
            {\box_ht:c {g_ropas_child_#1_content_box}} > {0pt}
            {\dim_add:Nn \l_ropas_tmpc_dim {\l_ropas_paragraph_leading_dim}}
        }
      \prop_get:NxN \g_ropas_data_prop { child/#1/title-height } \l_ropas_tmpd_tl
      \prop_get:NxN \g_ropas_data_prop { child/#1/title-present }
        \l_ropas_child_tl
      \prop_get:NxN \g_ropas_data_prop { child/#1/body-present } \l_tmpa_tl
      \str_if_eq:VnT \l_ropas_child_tl { true }
        {
          \bool_set:Nn \l_tmpa_bool
            {
              \str_if_eq_p:Vn \l_tmpa_tl { true }
              || \dim_compare_p:nNn {\l_tmpa_dim} > {0pt}
              || \dim_compare_p:nNn {\l_tmpb_dim} > {0pt}
            }
          \bool_if:NT \l_tmpa_bool
            {
              \dim_add:Nn \l_ropas_tmpc_dim { \l_ropas_paragraph_leading_dim }
            }
          \dim_add:Nn \l_ropas_tmpc_dim { \l_ropas_tmpd_tl }
        }
      \dim_set:Nn \l_tmpa_dim
        { \box_ht:c {g_ropas_child_#1_footnote_box}
          + \box_dp:c {g_ropas_child_#1_footnote_box} }
      \dim_compare:nNnT {\l_tmpa_dim} > {0pt}
        {
          \dim_add:Nn \l_ropas_tmpc_dim {\l_tmpa_dim}
          \dim_add:Nn \l_ropas_tmpc_dim {\l_ropas_paragraph_leading_dim}
        }
      \prop_gput:Nxx \g_ropas_data_prop { child/#1/content-min-height }
        { \dim_use:N \l_ropas_tmpc_dim }
      \dim_gset:Nn \g_ropas_return_dim
        { \l_ropas_tmpc_dim + 2 \l_ropas_margin_dim
          + \l_ropas_sep_top_dim + \l_ropas_sep_bottom_dim }
    \group_end:
  }

\cs_new_protected:Npn \ropas_measure_grid_block:nn #1#2
  {
    \group_begin:
      \dim_set:Nn \l_ropas_cell_outer_width_dim {#2}
      \ropas_load_style_from_child:n {#1}
      \ropas_block_side_separations:n {#1}
      \dim_set:Nn \l_tmpa_dim
        { \l_ropas_cell_outer_width_dim
          - \l_ropas_sep_left_dim - \l_ropas_sep_right_dim
          - 2\l_ropas_margin_dim }
      \dim_compare:nNnF {\l_tmpa_dim} > {0pt}
        {
          \ropas_class_error:nn { Grid~block~has~no~positive~inner~width }
            { Reduce~the~block~separation~or~margin. }
          \dim_set:Nn \l_tmpa_dim {1pt}
        }
      \bool_gset_false:N \g_ropas_horizontal_overflow_bool
      \bool_set_false:N \l_ropas_cell_title_seen_bool
      \box_gclear:c { g_ropas_child_#1_title_box }
      \prop_gput:Nnn \g_ropas_data_prop { child/#1/title-present } { false }
      \prop_gput:Nnn \g_ropas_data_prop { child/#1/title-height } { 0pt }
      \prop_gput:Nnn \g_ropas_data_prop { child/#1/title-width } { 0pt }
      \prop_get:NxN \g_ropas_data_prop
        { child/#1/container-title } \l_ropas_tmpc_tl
      \tl_if_blank:VF \l_ropas_tmpc_tl
        {
          \cs_set_eq:NN \ropas_saved_par: \par
          \exp_args:NnnV \ropas_typeset_cell_title:nnn
            {#1}{\l_tmpa_dim}\l_ropas_tmpc_tl
        }
      \prop_get:NxN \g_ropas_data_prop { child/#1/grid } \l_ropas_tmpd_tl
      \ropas_grid_measure_min:nn {\l_ropas_tmpd_tl}{\l_tmpa_dim}
      \dim_set_eq:NN \l_ropas_tmpc_dim \g_ropas_return_dim
      \prop_gput:Nxx \g_ropas_data_prop { child/#1/body-min-height }
        { \dim_use:N \l_ropas_tmpc_dim }
      \prop_get:NxN \g_ropas_data_prop { child/#1/title-present } \l_tmpa_tl
      \str_if_eq:VnT \l_tmpa_tl { true }
        {
          \prop_get:NxN \g_ropas_data_prop { child/#1/title-height }
            \l_tmpa_tl
          \dim_add:Nn \l_ropas_tmpc_dim
            { \l_tmpa_tl + \l_ropas_paragraph_leading_dim }
        }
      \prop_gput:Nxx \g_ropas_data_prop { child/#1/content-min-height }
        { \dim_use:N \l_ropas_tmpc_dim }
      \bool_if:NTF \g_ropas_horizontal_overflow_bool
        { \prop_gput:Nnn \g_ropas_data_prop { child/#1/h-overflow } { true } }
        { \prop_gput:Nnn \g_ropas_data_prop { child/#1/h-overflow } { false } }
      \dim_gset:Nn \g_ropas_return_dim
        { \l_ropas_tmpc_dim + 2\l_ropas_margin_dim
          + \l_ropas_sep_top_dim + \l_ropas_sep_bottom_dim }
    \group_end:
  }

% --------------------------------------------------------------------------
% Grid measurement and row allocation
% --------------------------------------------------------------------------

\clist_new:N \l_ropas_children_clist
\clist_new:N \l_ropas_ratios_clist
\dim_new:N \l_ropas_numeric_required_dim
\dim_new:N \l_ropas_grid_width_dim
\dim_new:N \l_ropas_grid_height_dim
\dim_new:N \l_ropas_cell_width_dim
\dim_new:N \l_ropas_cell_height_dim
\dim_new:N \l_ropas_cell_outer_width_dim
\dim_new:N \l_ropas_cell_background_width_dim
\dim_new:N \l_ropas_cell_background_height_dim
\dim_new:N \l_ropas_cell_inner_height_dim
\dim_new:N \l_ropas_cell_background_offset_dim
\dim_new:N \l_ropas_cell_background_y_offset_dim
\dim_new:N \l_ropas_cell_content_offset_dim
\dim_new:N \l_ropas_cell_content_y_offset_dim
\dim_new:N \l_ropas_cell_title_height_dim
\dim_new:N \l_ropas_cell_title_separator_dim
\dim_new:N \l_ropas_body_used_height_dim
\dim_new:N \l_ropas_flow_available_height_dim
\dim_new:N \l_ropas_footnote_height_dim
\dim_new:N \l_ropas_footnote_separator_dim
\dim_new:N \l_ropas_top_float_height_dim
\dim_new:N \l_ropas_bottom_float_height_dim
\dim_new:N \l_ropas_top_float_separator_dim
\dim_new:N \l_ropas_bottom_float_separator_dim
\dim_new:N \l_ropas_cell_body_height_dim
\cs_new_protected:Npn \ropas_grid_prepare_columns:nn #1#2
  {
    \dim_set:Nn \l_ropas_grid_width_dim {#2}
    \prop_gput:Nxx \g_ropas_data_prop { layout/#1/width }
      { \dim_use:N \l_ropas_grid_width_dim }
    \prop_get:NxN \g_ropas_data_prop { grid/#1/cols } \l_tmpa_tl
    \prop_get:NxN \g_ropas_data_prop { grid/#1/col-ratio } \l_tmpb_tl
    \clist_set:NV \l_ropas_ratios_clist \l_tmpb_tl
    \fp_zero:N \l_ropas_ratio_sum_fp
    \clist_map_inline:Nn \l_ropas_ratios_clist
      { \fp_add:Nn \l_ropas_ratio_sum_fp {##1} }
    \dim_zero:N \l_tmpa_dim
    \int_step_inline:nn { \l_tmpa_tl }
      {
        \int_compare:nNnTF {##1} = { \l_tmpa_tl }
          {
            \dim_set:Nn \l_tmpb_dim
              { \l_ropas_grid_width_dim - \l_tmpa_dim }
          }
          {
            \dim_set:Nn \l_tmpb_dim
              {
                \fp_to_dim:n
                  {
                    \dim_to_fp:n { \l_ropas_grid_width_dim }
                    * \clist_item:Nn \l_ropas_ratios_clist {##1}
                    / \l_ropas_ratio_sum_fp
                  }
              }
          }
        \prop_gput:Nxx \g_ropas_data_prop { layout/#1/col/##1 }
          { \dim_use:N \l_tmpb_dim }
        \dim_add:Nn \l_tmpa_dim { \l_tmpb_dim }
      }
  }
\cs_new_protected:Npn \ropas_child_width:nN #1#2
  {
    \prop_get:NxN \g_ropas_data_prop { child/#1/parent } \l_tmpa_tl
    \prop_get:NxN \g_ropas_data_prop { child/#1/col-start } \l_tmpb_tl
    \prop_get:NxN \g_ropas_data_prop { child/#1/col-end } \l_ropas_tmpc_tl
    \dim_zero:N #2
    \int_step_inline:nnn { \l_tmpb_tl } { \l_ropas_tmpc_tl }
      {
        \prop_get:NxN \g_ropas_data_prop
          { layout/\l_tmpa_tl/col/##1 } \l_ropas_tmpd_tl
        \dim_add:Nn #2 { \l_ropas_tmpd_tl }
      }
  }

\cs_new_protected:Npn \ropas_measure_grid_children:n #1
  {
    \tl_set:Nx \l_ropas_grid_tl {#1}
    \prop_get:NxN \g_ropas_data_prop { grid/\l_ropas_grid_tl/children }
      \l_tmpa_tl
    \clist_set:NV \l_ropas_children_clist \l_tmpa_tl
    \clist_map_inline:Nn \l_ropas_children_clist
      {
        \ropas_child_width:nN {##1} \l_tmpa_dim
        \prop_get:NxN \g_ropas_data_prop { child/##1/type } \l_tmpb_tl
        \str_case:VnF \l_tmpb_tl
          {
            { block }
              { \ropas_measure_cell:nn {##1}{\l_tmpa_dim} }
            { grid-block }
              { \ropas_measure_grid_block:nn {##1}{\l_tmpa_dim} }
            { subgrid }
              {
                \prop_get:NxN \g_ropas_data_prop
                  { child/##1/grid } \l_ropas_tmpd_tl
                % A structural block passes its complete parent-track geometry
                % to the nested grid, so ratios compose without an inset.
                \ropas_grid_measure_min:nn {\l_ropas_tmpd_tl}{\l_tmpa_dim}
              }
            { empty-subgrid }
              { \dim_gzero:N \g_ropas_return_dim }
          }
          {
            \ropas_class_error:nn { Unknown~posterblock~type~'\l_tmpb_tl' }
              { This~is~an~internal~ropas-poster~error. }
            \dim_gzero:N \g_ropas_return_dim
          }
        \prop_gput:Nxx \g_ropas_data_prop { child/##1/min-height }
          { \dim_use:N \g_ropas_return_dim }
      }
  }

\cs_new_protected:Npn \ropas_init_row_minima:n #1
  {
    \seq_clear:N \l_ropas_row_dims_seq
    \seq_clear:N \l_ropas_row_types_seq
    \prop_get:NxN \g_ropas_data_prop { grid/#1/row-ratio } \l_tmpa_tl
    \clist_set:NV \l_ropas_ratios_clist \l_tmpa_tl
    \clist_map_inline:Nn \l_ropas_ratios_clist
      {
        \seq_put_right:Nn \l_ropas_row_dims_seq { 0pt }
        \tl_set:Nx \l_tmpa_tl { \tl_trim_spaces:n {##1} }
        \str_if_eq:VnTF \l_tmpa_tl { auto }
          { \seq_put_right:Nn \l_ropas_row_types_seq { auto } }
          {
            \str_if_eq:VnTF \l_tmpa_tl { min }
              { \seq_put_right:Nn \l_ropas_row_types_seq { min } }
              { \seq_put_right:Nn \l_ropas_row_types_seq { numeric } }
          }
      }
  }

\cs_new_protected:Npn \ropas_numeric_minimum:n #1
  {
    \dim_zero:N \l_ropas_numeric_required_dim
    \prop_get:NxN \g_ropas_data_prop { grid/#1/row-ratio } \l_tmpa_tl
    \clist_set:NV \l_ropas_ratios_clist \l_tmpa_tl
    \fp_zero:N \l_ropas_ratio_sum_fp
    \int_step_inline:nn { \seq_count:N \l_ropas_row_types_seq }
      {
        \str_if_eq:eeT { \seq_item:Nn \l_ropas_row_types_seq {##1} }
          { numeric }
          { \fp_add:Nn \l_ropas_ratio_sum_fp
              { \clist_item:Nn \l_ropas_ratios_clist {##1} } }
      }
    \prop_get:NxN \g_ropas_data_prop { grid/#1/children } \l_tmpa_tl
    \clist_set:NV \l_ropas_children_clist \l_tmpa_tl
    \clist_map_inline:Nn \l_ropas_children_clist
      {
        \prop_get:NxN \g_ropas_data_prop { child/##1/row-start } \l_tmpa_tl
        \prop_get:NxN \g_ropas_data_prop { child/##1/row-end } \l_tmpb_tl
        \prop_get:NxN \g_ropas_data_prop { child/##1/min-height } \l_ropas_tmpc_tl
        \int_zero:N \l_tmpa_int
        \fp_zero:N \l_tmpa_fp
        \int_step_inline:nnn { \l_tmpa_tl } { \l_tmpb_tl }
          {
            \str_if_eq:eeTF
              { \seq_item:Nn \l_ropas_row_types_seq {####1} } { numeric }
              { \fp_add:Nn \l_tmpa_fp
                  { \clist_item:Nn \l_ropas_ratios_clist {####1} } }
              { \int_incr:N \l_tmpa_int }
          }
        \int_compare:nNnT { \l_tmpa_int } = {0}
          {
            \fp_compare:nNnT { \l_tmpa_fp } > {0}
              {
                \int_set:Nn \l_ropas_tmpd_int
                  {
                    \fp_eval:n
                      {
                        ceil(
                          \dim_to_decimal_in_sp:n { \l_ropas_tmpc_tl }
                          * \l_ropas_ratio_sum_fp / \l_tmpa_fp
                        )
                      }
                  }
                \dim_set:Nn \l_tmpa_dim { \l_ropas_tmpd_int sp }
                \dim_compare:nNnT { \l_tmpa_dim } >
                  { \l_ropas_numeric_required_dim }
                  { \dim_set_eq:NN \l_ropas_numeric_required_dim \l_tmpa_dim }
              }
          }
      }
  }

% Exact minimum totals and variance-balanced row allocation
% --------------------------------------------------------------------------

\prop_new:N \l_ropas_min_prefix_prop
\prop_new:N \l_ropas_selected_row_dim_prop
\prop_new:N \l_ropas_first_initial_row_prop
\prop_new:N \l_ropas_second_initial_row_prop
\bool_new:N \l_ropas_min_previous_bool
\bool_new:N \l_ropas_min_child_selected_bool
\bool_new:N \l_ropas_first_constraints_bool
\bool_new:N \l_ropas_second_constraints_bool
\bool_new:N \l_ropas_qp_first_cover_bool
\bool_new:N \l_ropas_qp_second_cover_bool
\bool_new:N \l_ropas_qp_constraints_bool
\int_new:N \l_ropas_min_total_rows_int
\int_new:N \l_ropas_min_child_start_int
\int_new:N \l_ropas_min_child_end_int
\seq_new:N \l_ropas_row_groups_seq
\seq_new:N \l_ropas_row_sp_seq
\prop_new:N \l_ropas_qp_hessian_prop
\prop_new:N \l_ropas_qp_linear_prop
\prop_new:N \l_ropas_qp_gradient_prop
\prop_new:N \l_ropas_qp_row_count_prop
\prop_new:N \l_ropas_qp_row_minimum_prop
\clist_new:N \l_ropas_column_children_clist
\dim_new:N \l_ropas_selected_minimum_dim
\dim_new:N \l_ropas_available_height_dim
\int_new:N \l_ropas_available_sp_int
\int_new:N \l_ropas_first_target_sp_int
\int_new:N \l_ropas_second_target_sp_int
\int_new:N \l_ropas_numeric_target_sp_int
\int_new:N \l_ropas_numeric_rows_int
\int_new:N \l_ropas_auto_rows_int
\int_new:N \l_ropas_min_rows_int
\int_new:N \l_ropas_tmpd_int
\int_new:N \l_ropas_qp_best_delta_int
\fp_new:N \l_ropas_qp_pair_gradient_fp
\fp_new:N \l_ropas_qp_pair_curvature_fp
\fp_new:N \l_ropas_qp_best_change_fp
\fp_new:N \l_ropas_qp_candidate_change_fp
\tl_new:N \l_ropas_qp_existing_tl
\bool_new:N \l_ropas_qp_improved_bool
\int_new:N \l_ropas_qp_pass_int
\int_new:N \l_ropas_qp_cell_count_int
\int_new:N \l_ropas_qp_row_count_int
\int_new:N \l_ropas_qp_common_count_int
\int_new:N \l_ropas_qp_first_row_int
\int_new:N \l_ropas_qp_child_start_int
\int_new:N \l_ropas_qp_child_end_int
\int_new:N \l_ropas_qp_cell_height_sp_int
\int_new:N \l_ropas_qp_cell_minimum_sp_int
\int_new:N \l_ropas_qp_cell_slack_sp_int
\fp_new:N \l_ropas_qp_total_minimum_fp
\fp_new:N \l_ropas_qp_row_minimum_fp

\prg_new_protected_conditional:Npnn \ropas_row_selected:nn #1#2 { T,F,TF }
  {
    \tl_set:Nx \l_tmpa_tl { \seq_item:Nn \l_ropas_row_types_seq {#1} }
    \str_case:nnF {#2}
      {
        { all } { \prg_return_true: }
        { min }
          {
            \str_if_eq:VnTF \l_tmpa_tl { min }
              { \prg_return_true: } { \prg_return_false: }
          }
        { auto }
          {
            \str_if_eq:VnTF \l_tmpa_tl { auto }
              { \prg_return_true: } { \prg_return_false: }
          }
        { nonnumeric }
          {
            \str_if_eq:VnTF \l_tmpa_tl { numeric }
              { \prg_return_false: } { \prg_return_true: }
          }
      }
      { \prg_return_false: }
  }

\prg_new_protected_conditional:Npnn
  \ropas_child_rows_selected:nn #1#2 { T,F,TF }
  {
    \bool_set_true:N \l_ropas_min_child_selected_bool
    \prop_get:NxN \g_ropas_data_prop { child/#1/row-start } \l_tmpa_tl
    \prop_get:NxN \g_ropas_data_prop { child/#1/row-end } \l_tmpb_tl
    \int_set:Nn \l_ropas_min_child_start_int { \l_tmpa_tl }
    \int_set:Nn \l_ropas_min_child_end_int { \l_tmpb_tl }
    \int_step_inline:nnn
      { \l_ropas_min_child_start_int } { \l_ropas_min_child_end_int }
      {
        \ropas_row_selected:nnF {##1}{#2}
          { \bool_set_false:N \l_ropas_min_child_selected_bool }
      }
    \bool_if:NTF \l_ropas_min_child_selected_bool
      { \prg_return_true: } { \prg_return_false: }
  }

% For a selected set of rows, constraints never cross an unselected row.
% Within each selected run, prefix heights form a forward longest-path
% problem: p_b >= p_(a-1) + minimum(cell).  The least prefixes therefore give
% both the exact least total and one simple attaining row vector.
\cs_new_protected:Npn \ropas_compute_selected_minimum:nnN #1#2#3
  {
    \prop_clear:N \l_ropas_min_prefix_prop
    \prop_clear:N \l_ropas_selected_row_dim_prop
    \dim_zero:N #3
    \bool_set_false:N \l_ropas_min_previous_bool
    \prop_get:NxN \g_ropas_data_prop { grid/#1/rows } \l_tmpa_tl
    \int_set:Nn \l_ropas_min_total_rows_int { \l_tmpa_tl }
    \prop_get:NxN \g_ropas_data_prop { grid/#1/children } \l_tmpb_tl
    \clist_set:NV \l_ropas_children_clist \l_tmpb_tl
    \int_step_inline:nn { \l_ropas_min_total_rows_int }
      {
        \ropas_row_selected:nnTF {##1}{#2}
          {
            \bool_if:NF \l_ropas_min_previous_bool
              {
                \prop_put:Nxx \l_ropas_min_prefix_prop
                  { \int_eval:n {##1-1} } { 0pt }
              }
            \prop_get:NxN \l_ropas_min_prefix_prop
              { \int_eval:n {##1-1} } \l_ropas_tmpc_tl
            \dim_set:Nn \l_tmpa_dim { \l_ropas_tmpc_tl }
            \clist_map_inline:Nn \l_ropas_children_clist
              {
                \prop_get:NxN \g_ropas_data_prop { child/####1/row-end }
                  \l_ropas_tmpd_tl
                \int_compare:nNnT { \l_ropas_tmpd_tl } = {##1}
                  {
                    \ropas_child_rows_selected:nnT {####1}{#2}
                      {
                        \prop_get:NxN \g_ropas_data_prop
                          { child/####1/row-start } \l_ropas_tmpd_tl
                        \prop_get:NxN \l_ropas_min_prefix_prop
                          { \int_eval:n {\l_ropas_tmpd_tl-1} } \l_ropas_child_tl
                        \prop_get:NxN \g_ropas_data_prop
                          { child/####1/min-height } \l_ropas_tmpd_tl
                        \dim_set:Nn \l_tmpb_dim
                          { \l_ropas_child_tl + \l_ropas_tmpd_tl }
                        \dim_compare:nNnT { \l_tmpb_dim } > { \l_tmpa_dim }
                          { \dim_set_eq:NN \l_tmpa_dim \l_tmpb_dim }
                      }
                  }
              }
            \prop_put:Nxx \l_ropas_min_prefix_prop {##1}
              { \dim_use:N \l_tmpa_dim }
            \dim_set:Nn \l_tmpb_dim { \l_tmpa_dim - \l_ropas_tmpc_tl }
            \prop_put:Nxx \l_ropas_selected_row_dim_prop {##1}
              { \dim_use:N \l_tmpb_dim }
            \bool_set_true:N \l_ropas_min_previous_bool
          }
          {
            \bool_if:NT \l_ropas_min_previous_bool
              {
                \prop_get:NxN \l_ropas_min_prefix_prop
                  { \int_eval:n {##1-1} } \l_ropas_tmpc_tl
                \dim_add:Nn #3 { \l_ropas_tmpc_tl }
              }
            \prop_put:Nnn \l_ropas_selected_row_dim_prop {##1} {0pt}
            \prop_put:Nnn \l_ropas_min_prefix_prop {##1} {0pt}
            \bool_set_false:N \l_ropas_min_previous_bool
          }
      }
    \bool_if:NT \l_ropas_min_previous_bool
      {
        \prop_get:NxN \l_ropas_min_prefix_prop
          { \int_use:N \l_ropas_min_total_rows_int } \l_ropas_tmpc_tl
        \dim_add:Nn #3 { \l_ropas_tmpc_tl }
      }
  }

\cs_new_protected:Npn \ropas_qp_add_to_prop:Nnn #1#2#3
  {
    \prop_get:NxNTF #1 {#2} \l_ropas_qp_existing_tl
      {
        \prop_put:Nnx #1 {#2}
          { \fp_eval:n { \l_ropas_qp_existing_tl + (#3) } }
      }
      { \prop_put:Nnx #1 {#2} { \fp_eval:n {#3} } }
  }

\prg_new_protected_conditional:Npnn
  \ropas_child_covers_column:nn #1#2 { T,F,TF }
  {
    \prop_get:NxN \g_ropas_data_prop { child/#1/col-start } \l_tmpa_tl
    \prop_get:NxN \g_ropas_data_prop { child/#1/col-end } \l_tmpb_tl
    \int_set:Nn \l_ropas_qp_child_start_int { \l_tmpa_tl }
    \int_set:Nn \l_ropas_qp_child_end_int { \l_tmpb_tl }
    \int_compare:nNnTF { \l_ropas_qp_child_start_int } > {#2}
      { \prg_return_false: }
      {
        \int_compare:nNnTF { \l_ropas_qp_child_end_int } < {#2}
          { \prg_return_false: } { \prg_return_true: }
      }
  }

\prg_new_protected_conditional:Npnn
  \ropas_child_covers_row:nn #1#2 { T,F,TF }
  {
    \prop_get:NxN \g_ropas_data_prop { child/#1/row-start } \l_tmpa_tl
    \prop_get:NxN \g_ropas_data_prop { child/#1/row-end } \l_tmpb_tl
    \int_set:Nn \l_ropas_qp_child_start_int { \l_tmpa_tl }
    \int_set:Nn \l_ropas_qp_child_end_int { \l_tmpb_tl }
    \int_compare:nNnTF { \l_ropas_qp_child_start_int } > {#2}
      { \prg_return_false: }
      {
        \int_compare:nNnTF { \l_ropas_qp_child_end_int } < {#2}
          { \prg_return_false: } { \prg_return_true: }
      }
  }

\cs_new_protected:Npn \ropas_qp_collect_row_statistics:n #1
  {
    \int_zero:N \l_ropas_qp_row_count_int
    \fp_zero:N \l_ropas_qp_row_minimum_fp
    \clist_map_inline:Nn \l_ropas_column_children_clist
      {
        \ropas_child_covers_row:nnT {##1}{#1}
          {
            \int_incr:N \l_ropas_qp_row_count_int
            \prop_get:NxN \g_ropas_data_prop { child/##1/min-height }
              \l_tmpa_tl
            \fp_add:Nn \l_ropas_qp_row_minimum_fp
              { \dim_to_decimal_in_sp:n { \l_tmpa_tl } }
          }
      }
    \prop_put:Nnx \l_ropas_qp_row_count_prop {#1}
      { \int_use:N \l_ropas_qp_row_count_int }
    \prop_put:Nnx \l_ropas_qp_row_minimum_prop {#1}
      { \fp_use:N \l_ropas_qp_row_minimum_fp }
  }

\cs_new_protected:Npn \ropas_qp_common_count:nn #1#2
  {
    \int_zero:N \l_ropas_qp_common_count_int
    \clist_map_inline:Nn \l_ropas_column_children_clist
      {
        \ropas_child_covers_row:nnT {##1}{#1}
          {
            \ropas_child_covers_row:nnT {##1}{#2}
              { \int_incr:N \l_ropas_qp_common_count_int }
          }
      }
  }

\cs_new_protected:Npn \ropas_qp_add_hessian_entry:nn #1#2
  {
    \ropas_qp_common_count:nn {#1}{#2}
    \prop_get:NnN \l_ropas_qp_row_count_prop {#1} \l_tmpa_tl
    \prop_get:NnN \l_ropas_qp_row_count_prop {#2} \l_tmpb_tl
    \ropas_qp_add_to_prop:Nnn \l_ropas_qp_hessian_prop {#1/#2}
      {
        2 * \l_ropas_qp_common_count_int / \l_ropas_qp_cell_count_int
      }
  }

\cs_new_protected:Npn \ropas_qp_add_hessian_row:n #1
  {
    \int_step_inline:nn { \l_ropas_min_total_rows_int }
      { \ropas_qp_add_hessian_entry:nn {#1}{##1} }
  }

\cs_new_protected:Npn \ropas_qp_add_linear_entry:n #1
  {
    \prop_get:NnN \l_ropas_qp_row_count_prop {#1} \l_tmpa_tl
    \prop_get:NnN \l_ropas_qp_row_minimum_prop {#1} \l_tmpb_tl
    \ropas_qp_add_to_prop:Nnn \l_ropas_qp_linear_prop {#1}
      {
        -2 * \l_tmpb_tl / \l_ropas_qp_cell_count_int
      }
  }

\cs_new_protected:Npn \ropas_qp_build_column:nn #1#2
  {
    \clist_clear:N \l_ropas_column_children_clist
    \clist_map_inline:Nn \l_ropas_children_clist
      {
        \ropas_child_covers_column:nnT {##1}{#2}
          { \clist_put_right:Nn \l_ropas_column_children_clist {##1} }
      }
    \int_set:Nn \l_ropas_qp_cell_count_int
      { \clist_count:N \l_ropas_column_children_clist }
    \int_compare:nNnT { \l_ropas_qp_cell_count_int } > {0}
      {
        \fp_zero:N \l_ropas_qp_total_minimum_fp
        \clist_map_inline:Nn \l_ropas_column_children_clist
          {
            \prop_get:NxN \g_ropas_data_prop { child/##1/min-height }
              \l_tmpa_tl
            \fp_add:Nn \l_ropas_qp_total_minimum_fp
              { \dim_to_decimal_in_sp:n { \l_tmpa_tl } }
          }
        \prop_clear:N \l_ropas_qp_row_count_prop
        \prop_clear:N \l_ropas_qp_row_minimum_prop
        \int_step_function:nN { \l_ropas_min_total_rows_int }
          \ropas_qp_collect_row_statistics:n
        \int_step_function:nN { \l_ropas_min_total_rows_int }
          \ropas_qp_add_linear_entry:n
        \int_step_function:nN { \l_ropas_min_total_rows_int }
          \ropas_qp_add_hessian_row:n
      }
  }

% Build the Hessian and linear term of the sum of columnwise mean squared
% differences between allocated and minimum block heights.  A
% child spanning rows contributes one height to a column, never one per row;
% a child spanning columns occurs once in each covered column's cell set.
\cs_new_protected:Npn \ropas_qp_build_objective:n #1
  {
    \prop_clear:N \l_ropas_qp_hessian_prop
    \prop_clear:N \l_ropas_qp_linear_prop
    \prop_get:NxN \g_ropas_data_prop { grid/#1/rows } \l_tmpa_tl
    \int_set:Nn \l_ropas_min_total_rows_int { \l_tmpa_tl }
    \prop_get:NxN \g_ropas_data_prop { grid/#1/cols } \l_tmpa_tl
    \int_set:Nn \l_tmpa_int { \l_tmpa_tl }
    \prop_get:NxN \g_ropas_data_prop { grid/#1/children } \l_tmpa_tl
    \clist_set:NV \l_ropas_children_clist \l_tmpa_tl
    \int_step_inline:nn { \l_ropas_min_total_rows_int }
      {
        \prop_put:Nnn \l_ropas_qp_linear_prop {##1} {0}
        \int_set:Nn \l_ropas_qp_first_row_int {##1}
        \int_step_inline:nn { \l_ropas_min_total_rows_int }
          {
            \prop_put:Nxx \l_ropas_qp_hessian_prop
              { \int_use:N \l_ropas_qp_first_row_int / ####1 } {0}
          }
      }
    \int_step_inline:nn { \l_tmpa_int }
      { \ropas_qp_build_column:nn {#1}{##1} }
  }

\cs_new_protected:Npn \ropas_qp_distribute_group:nn #1#2
  {
    \int_zero:N \l_tmpa_int
    \seq_map_inline:Nn \l_ropas_row_groups_seq
      { \str_if_eq:nnT {##1}{#1} { \int_incr:N \l_tmpa_int } }
    \int_compare:nNnT { \l_tmpa_int } > {0}
      {
        \int_set:Nn \l_tmpb_int { \int_div_truncate:nn {#2}{\l_tmpa_int} }
        \int_set:Nn \l_ropas_tmpc_int { \int_mod:nn {#2}{\l_tmpa_int} }
        \int_zero:N \l_tmpa_int
        \int_step_inline:nn { \seq_count:N \l_ropas_row_groups_seq }
          {
            \str_if_eq:eeT
              { \seq_item:Nn \l_ropas_row_groups_seq {##1} } {#1}
              {
                \int_incr:N \l_tmpa_int
                \int_set:Nn \l_ropas_tmpd_int { \l_tmpb_int }
                \int_compare:nNnT { \l_tmpa_int } < { \l_ropas_tmpc_int + 1 }
                  { \int_incr:N \l_ropas_tmpd_int }
                \seq_set_item:Nnx \l_ropas_row_sp_seq {##1}
                  { \int_use:N \l_ropas_tmpd_int }
              }
          }
      }
  }

\cs_new_protected:Npn \ropas_qp_capture_selected_rows:N #1
  {
    \prop_clear:N #1
    \int_step_inline:nn { \seq_count:N \l_ropas_row_types_seq }
      {
        \prop_get:NnN \l_ropas_selected_row_dim_prop {##1} \l_tmpa_tl
        \prop_put:NnV #1 {##1} \l_tmpa_tl
      }
  }

\cs_new_protected:Npn \ropas_qp_add_to_group:nn #1#2
  {
    \int_zero:N \l_tmpa_int
    \seq_map_inline:Nn \l_ropas_row_groups_seq
      { \str_if_eq:nnT {##1}{#1} { \int_incr:N \l_tmpa_int } }
    \int_compare:nNnT { \l_tmpa_int } > {0}
      {
        \int_set:Nn \l_tmpb_int { \int_div_truncate:nn {#2}{\l_tmpa_int} }
        \int_set:Nn \l_ropas_tmpc_int { \int_mod:nn {#2}{\l_tmpa_int} }
        \int_zero:N \l_tmpa_int
        \int_step_inline:nn { \seq_count:N \l_ropas_row_groups_seq }
          {
            \str_if_eq:eeT
              { \seq_item:Nn \l_ropas_row_groups_seq {##1} } {#1}
              {
                \int_incr:N \l_tmpa_int
                \int_set:Nn \l_ropas_tmpd_int
                  {
                    \seq_item:Nn \l_ropas_row_sp_seq {##1}
                    + \l_tmpb_int
                  }
                \int_compare:nNnT { \l_tmpa_int } < { \l_ropas_tmpc_int + 1 }
                  { \int_incr:N \l_ropas_tmpd_int }
                \seq_set_item:Nnx \l_ropas_row_sp_seq {##1}
                  { \int_use:N \l_ropas_tmpd_int }
              }
          }
      }
  }

\cs_new_protected:Npn \ropas_qp_initialise_feasible_group:nnn #1#2#3
  {
    \int_zero:N \l_tmpa_int
    \int_step_inline:nn { \seq_count:N \l_ropas_row_groups_seq }
      {
        \str_if_eq:eeT
          { \seq_item:Nn \l_ropas_row_groups_seq {##1} } {#1}
          {
            \prop_get:NnN #2 {##1} \l_tmpa_tl
            \int_set:Nn \l_tmpb_int
              { \dim_to_decimal_in_sp:n { \l_tmpa_tl } }
            \seq_set_item:Nnx \l_ropas_row_sp_seq {##1}
              { \int_use:N \l_tmpb_int }
            \int_add:Nn \l_tmpa_int { \l_tmpb_int }
          }
      }
    \int_set:Nn \l_ropas_tmpd_int { #3 - \l_tmpa_int }
    \ropas_qp_add_to_group:nn {#1}{ \l_ropas_tmpd_int }
  }

\cs_new_protected:Npn \ropas_qp_initialise_gradient:
  {
    \prop_clear:N \l_ropas_qp_gradient_prop
    \int_step_inline:nn { \seq_count:N \l_ropas_row_sp_seq }
      {
        \prop_get:NnN \l_ropas_qp_linear_prop {##1} \l_tmpa_tl
        \fp_set:Nn \l_tmpa_fp { \l_tmpa_tl }
        \int_step_inline:nn { \seq_count:N \l_ropas_row_sp_seq }
          {
            \prop_get:NnN \l_ropas_qp_hessian_prop
              {##1/####1} \l_tmpb_tl
            \fp_add:Nn \l_tmpa_fp
              { \l_tmpb_tl * \seq_item:Nn \l_ropas_row_sp_seq {####1} }
          }
        \prop_put:Nnx \l_ropas_qp_gradient_prop {##1}
          { \fp_use:N \l_tmpa_fp }
      }
  }

\cs_new_protected:Npn \ropas_qp_consider_delta:n #1
  {
    \int_set:Nn \l_tmpa_int {#1}
    \int_compare:nNnT { \l_tmpa_int } < { \l_tmpb_int }
      { \int_set_eq:NN \l_tmpa_int \l_tmpb_int }
    \int_compare:nNnT { \l_tmpa_int } > { \l_ropas_tmpc_int }
      { \int_set_eq:NN \l_tmpa_int \l_ropas_tmpc_int }
    \fp_set:Nn \l_ropas_qp_candidate_change_fp
      {
        \l_ropas_qp_pair_gradient_fp * \l_tmpa_int
        + .5 * \l_ropas_qp_pair_curvature_fp
          * \l_tmpa_int * \l_tmpa_int
      }
    \fp_compare:nNnT
      { \l_ropas_qp_candidate_change_fp } < { \l_ropas_qp_best_change_fp }
      {
        \fp_set_eq:NN \l_ropas_qp_best_change_fp
          \l_ropas_qp_candidate_change_fp
        \int_set_eq:NN \l_ropas_qp_best_delta_int \l_tmpa_int
      }
  }

\prg_new_protected_conditional:Npnn
  \ropas_child_inside_group:nn #1#2 { T,F,TF }
  {
    \bool_set_true:N \l_ropas_min_child_selected_bool
    \prop_get:NxN \g_ropas_data_prop { child/#1/row-start } \l_tmpa_tl
    \prop_get:NxN \g_ropas_data_prop { child/#1/row-end } \l_tmpb_tl
    \int_set:Nn \l_ropas_min_child_start_int { \l_tmpa_tl }
    \int_set:Nn \l_ropas_min_child_end_int { \l_tmpb_tl }
    \int_step_inline:nnn
      { \l_ropas_min_child_start_int } { \l_ropas_min_child_end_int }
      {
        \str_if_eq:eeF
          { \seq_item:Nn \l_ropas_row_groups_seq {##1} } {#2}
          { \bool_set_false:N \l_ropas_min_child_selected_bool }
      }
    \bool_if:NTF \l_ropas_min_child_selected_bool
      { \prg_return_true: } { \prg_return_false: }
  }

% Intersect a pair transfer's nonnegative-row interval with every active cell
% minimum.  A spanning cell changes only when exactly one of the two rows is
% inside it, so each constraint supplies one integer lower or upper bound.
\cs_new_protected:Npn \ropas_qp_restrict_pair:nnn #1#2#3
  {
    \bool_set_false:N \l_ropas_qp_constraints_bool
    \str_case:nn {#3}
      {
        { first }
          { \bool_set_eq:NN \l_ropas_qp_constraints_bool
              \l_ropas_first_constraints_bool }
        { second }
          { \bool_set_eq:NN \l_ropas_qp_constraints_bool
              \l_ropas_second_constraints_bool }
      }
    \bool_if:NT \l_ropas_qp_constraints_bool
      {
        \clist_map_inline:Nn \l_ropas_children_clist
          {
            \ropas_child_inside_group:nnT {##1}{#3}
              {
                \ropas_child_covers_row:nnTF {##1}{#1}
                  { \bool_set_true:N \l_ropas_qp_first_cover_bool }
                  { \bool_set_false:N \l_ropas_qp_first_cover_bool }
                \ropas_child_covers_row:nnTF {##1}{#2}
                  { \bool_set_true:N \l_ropas_qp_second_cover_bool }
                  { \bool_set_false:N \l_ropas_qp_second_cover_bool }
                \bool_if:nT
                  {
                    ( \l_ropas_qp_first_cover_bool
                      && ! \l_ropas_qp_second_cover_bool )
                    ||
                    ( ! \l_ropas_qp_first_cover_bool
                      && \l_ropas_qp_second_cover_bool )
                  }
                  {
                    \prop_get:NxN \g_ropas_data_prop
                      { child/##1/row-start } \l_tmpa_tl
                    \prop_get:NxN \g_ropas_data_prop
                      { child/##1/row-end } \l_tmpb_tl
                    \int_zero:N \l_ropas_qp_cell_height_sp_int
                    \int_step_inline:nnn { \l_tmpa_tl } { \l_tmpb_tl }
                      {
                        \int_add:Nn \l_ropas_qp_cell_height_sp_int
                          { \seq_item:Nn \l_ropas_row_sp_seq {####1} }
                      }
                    \prop_get:NxN \g_ropas_data_prop
                      { child/##1/min-height } \l_tmpa_tl
                    \int_set:Nn \l_ropas_qp_cell_minimum_sp_int
                      { \dim_to_decimal_in_sp:n { \l_tmpa_tl } }
                    \int_set:Nn \l_ropas_qp_cell_slack_sp_int
                      {
                        \l_ropas_qp_cell_height_sp_int
                        - \l_ropas_qp_cell_minimum_sp_int
                      }
                    \bool_if:NTF \l_ropas_qp_first_cover_bool
                      {
                        \int_compare:nNnT { \l_tmpb_int } <
                          { -\l_ropas_qp_cell_slack_sp_int }
                          {
                            \int_set:Nn \l_tmpb_int
                              { -\l_ropas_qp_cell_slack_sp_int }
                          }
                      }
                      {
                        \int_compare:nNnT { \l_ropas_tmpc_int } >
                          { \l_ropas_qp_cell_slack_sp_int }
                          {
                            \int_set_eq:NN \l_ropas_tmpc_int
                              \l_ropas_qp_cell_slack_sp_int
                          }
                      }
                  }
              }
          }
      }
  }

\cs_new_protected:Npn \ropas_qp_optimise_group:n #1
  {
    \bool_set_true:N \l_ropas_qp_improved_bool
    \int_zero:N \l_ropas_qp_pass_int
    \bool_while_do:nn
      {
        \l_ropas_qp_improved_bool
        && \int_compare_p:nNn { \l_ropas_qp_pass_int } < {50}
      }
      {
        \bool_set_false:N \l_ropas_qp_improved_bool
        \int_incr:N \l_ropas_qp_pass_int
        \int_step_inline:nn { \seq_count:N \l_ropas_row_sp_seq }
          {
            \str_if_eq:eeT
              { \seq_item:Nn \l_ropas_row_groups_seq {##1} } {#1}
              {
                \int_step_inline:nnn { \int_eval:n {##1+1} }
                  { \seq_count:N \l_ropas_row_sp_seq }
                  {
                    \str_if_eq:eeT
                      { \seq_item:Nn \l_ropas_row_groups_seq {####1} } {#1}
                      {
                        \prop_get:NnN \l_ropas_qp_gradient_prop {##1}
                          \l_tmpa_tl
                        \prop_get:NnN \l_ropas_qp_gradient_prop {####1}
                          \l_tmpb_tl
                        \fp_set:Nn \l_ropas_qp_pair_gradient_fp
                          { \l_tmpa_tl - \l_tmpb_tl }
                        \prop_get:NnN \l_ropas_qp_hessian_prop {##1/##1}
                          \l_tmpa_tl
                        \prop_get:NnN \l_ropas_qp_hessian_prop {####1/####1}
                          \l_tmpb_tl
                        \prop_get:NnN \l_ropas_qp_hessian_prop {##1/####1}
                          \l_ropas_tmpc_tl
                        \fp_set:Nn \l_ropas_qp_pair_curvature_fp
                          { \l_tmpa_tl + \l_tmpb_tl - 2 * \l_ropas_tmpc_tl }
                        \int_set:Nn \l_tmpb_int
                          { -\seq_item:Nn \l_ropas_row_sp_seq {##1} }
                        \int_set:Nn \l_ropas_tmpc_int
                          { \seq_item:Nn \l_ropas_row_sp_seq {####1} }
                        \ropas_qp_restrict_pair:nnn {##1}{####1}{#1}
                        \int_zero:N \l_ropas_qp_best_delta_int
                        \fp_zero:N \l_ropas_qp_best_change_fp
                        \fp_compare:nNnTF
                          { \l_ropas_qp_pair_curvature_fp } > {1e-12}
                          {
                            \fp_set:Nn \l_tmpa_fp
                              {
                                -\l_ropas_qp_pair_gradient_fp
                                  / \l_ropas_qp_pair_curvature_fp
                              }
                            % Clamp while this is still a floating-point
                            % value.  A mathematically flat direction can
                            % acquire a tiny rounded curvature, whose
                            % unconstrained minimiser is larger than TeX's
                            % integer range even though every feasible row
                            % transfer is safely within it.
                            \fp_compare:nNnT { \l_tmpa_fp } < { \l_tmpb_int }
                              { \fp_set:Nn \l_tmpa_fp { \l_tmpb_int } }
                            \fp_compare:nNnT { \l_tmpa_fp } > { \l_ropas_tmpc_int }
                              { \fp_set:Nn \l_tmpa_fp { \l_ropas_tmpc_int } }
                            \ropas_qp_consider_delta:n
                              { \fp_eval:n { floor(\l_tmpa_fp) } }
                            \ropas_qp_consider_delta:n
                              { \fp_eval:n { ceil(\l_tmpa_fp) } }
                          }
                          {
                            \fp_compare:nNnTF
                              { \l_ropas_qp_pair_gradient_fp } > {0}
                              { \ropas_qp_consider_delta:n { \l_tmpb_int } }
                              { \ropas_qp_consider_delta:n { \l_ropas_tmpc_int } }
                          }
                        \fp_compare:nNnT
                          { \l_ropas_qp_best_change_fp } < {-1e-12}
                          {
                            \int_set:Nn \l_tmpa_int
                              { \seq_item:Nn \l_ropas_row_sp_seq {##1}
                                + \l_ropas_qp_best_delta_int }
                            \seq_set_item:Nnx \l_ropas_row_sp_seq {##1}
                              { \int_use:N \l_tmpa_int }
                            \int_set:Nn \l_tmpa_int
                              { \seq_item:Nn \l_ropas_row_sp_seq {####1}
                                - \l_ropas_qp_best_delta_int }
                            \seq_set_item:Nnx \l_ropas_row_sp_seq {####1}
                              { \int_use:N \l_tmpa_int }
                            \int_step_inline:nn
                              { \seq_count:N \l_ropas_row_sp_seq }
                              {
                                \prop_get:NnN \l_ropas_qp_gradient_prop
                                  {########1} \l_tmpa_tl
                                \prop_get:NnN \l_ropas_qp_hessian_prop
                                  {########1/##1} \l_tmpb_tl
                                \prop_get:NnN \l_ropas_qp_hessian_prop
                                  {########1/####1} \l_ropas_tmpc_tl
                                \prop_put:Nnx \l_ropas_qp_gradient_prop
                                  {########1}
                                  {
                                    \fp_eval:n
                                      {
                                        \l_tmpa_tl
                                        + (\l_tmpb_tl-\l_ropas_tmpc_tl)
                                          * \l_ropas_qp_best_delta_int
                                      }
                                  }
                              }
                            \bool_set_true:N \l_ropas_qp_improved_bool
                          }
                      }
                  }
              }
          }
      }
  }

\cs_new_protected:Npn \ropas_prepare_row_groups:nn #1#2
  {
    \dim_set:Nn \l_ropas_available_height_dim {#2}
    \int_set:Nn \l_ropas_available_sp_int
      { \dim_to_decimal_in_sp:n { \l_ropas_available_height_dim } }
    \ropas_init_row_minima:n {#1}
    \int_zero:N \l_ropas_numeric_rows_int
    \int_zero:N \l_ropas_auto_rows_int
    \int_zero:N \l_ropas_min_rows_int
    \seq_map_inline:Nn \l_ropas_row_types_seq
      {
        \str_case:nn {##1}
          {
            { numeric } { \int_incr:N \l_ropas_numeric_rows_int }
            { auto }    { \int_incr:N \l_ropas_auto_rows_int }
            { min }     { \int_incr:N \l_ropas_min_rows_int }
          }
      }
    \seq_clear:N \l_ropas_row_groups_seq
    \seq_clear:N \l_ropas_row_sp_seq
    \int_step_inline:nn { \seq_count:N \l_ropas_row_types_seq }
      {
        \tl_set:Nx \l_tmpa_tl
          { \seq_item:Nn \l_ropas_row_types_seq {##1} }
        \int_compare:nNnTF { \l_ropas_numeric_rows_int } > {0}
          {
            \str_if_eq:VnTF \l_tmpa_tl { numeric }
              { \seq_put_right:Nn \l_ropas_row_groups_seq { fixed } }
              { \seq_put_right:Nn \l_ropas_row_groups_seq { first } }
          }
          {
            \str_if_eq:VnTF \l_tmpa_tl { auto }
              { \seq_put_right:Nn \l_ropas_row_groups_seq { second } }
              { \seq_put_right:Nn \l_ropas_row_groups_seq { first } }
          }
        \seq_put_right:Nn \l_ropas_row_sp_seq {0}
      }
    \int_zero:N \l_ropas_first_target_sp_int
    \int_zero:N \l_ropas_second_target_sp_int
    \int_zero:N \l_ropas_numeric_target_sp_int
    \bool_set_false:N \l_ropas_first_constraints_bool
    \bool_set_false:N \l_ropas_second_constraints_bool
    \prop_clear:N \l_ropas_first_initial_row_prop
    \prop_clear:N \l_ropas_second_initial_row_prop
    \int_compare:nNnTF { \l_ropas_numeric_rows_int } > {0}
      {
        \ropas_compute_selected_minimum:nnN {#1}{nonnumeric}
          \l_ropas_selected_minimum_dim
        \ropas_qp_capture_selected_rows:N \l_ropas_first_initial_row_prop
        \dim_compare:nNnF { \l_ropas_selected_minimum_dim } >
          { \l_ropas_available_height_dim }
          { \bool_set_true:N \l_ropas_first_constraints_bool }
        \dim_set:Nn \l_ropas_selected_minimum_dim
          { \dim_min:nn { \l_ropas_selected_minimum_dim }
              { \l_ropas_available_height_dim } }
        \int_set:Nn \l_ropas_first_target_sp_int
          { \dim_to_decimal_in_sp:n { \l_ropas_selected_minimum_dim } }
        \int_set:Nn \l_ropas_numeric_target_sp_int
          { \l_ropas_available_sp_int - \l_ropas_first_target_sp_int }
      }
      {
        \int_compare:nNnTF { \l_ropas_auto_rows_int } > {0}
          { \ropas_compute_selected_minimum:nnN {#1}{min}
              \l_ropas_selected_minimum_dim }
          { \ropas_compute_selected_minimum:nnN {#1}{all}
              \l_ropas_selected_minimum_dim }
        \ropas_qp_capture_selected_rows:N \l_ropas_first_initial_row_prop
        \dim_compare:nNnF { \l_ropas_selected_minimum_dim } >
          { \l_ropas_available_height_dim }
          { \bool_set_true:N \l_ropas_first_constraints_bool }
        \dim_set:Nn \l_ropas_selected_minimum_dim
          { \dim_min:nn { \l_ropas_selected_minimum_dim }
              { \l_ropas_available_height_dim } }
        \int_set:Nn \l_ropas_first_target_sp_int
          { \dim_to_decimal_in_sp:n { \l_ropas_selected_minimum_dim } }
        \int_compare:nNnT { \l_ropas_auto_rows_int } > {0}
          {
            \int_set:Nn \l_ropas_second_target_sp_int
              { \l_ropas_available_sp_int - \l_ropas_first_target_sp_int }
          }
      }
    \int_compare:nNnT { \l_ropas_auto_rows_int } > {0}
      {
        \ropas_compute_selected_minimum:nnN {#1}{auto}
          \l_ropas_selected_minimum_dim
        \ropas_qp_capture_selected_rows:N \l_ropas_second_initial_row_prop
        \int_set:Nn \l_tmpa_int
          { \dim_to_decimal_in_sp:n { \l_ropas_selected_minimum_dim } }
        \int_compare:nNnF { \l_tmpa_int } >
          { \l_ropas_second_target_sp_int }
          { \bool_set_true:N \l_ropas_second_constraints_bool }
      }
    \bool_if:NTF \l_ropas_first_constraints_bool
      {
        \ropas_qp_initialise_feasible_group:nnn {first}
          \l_ropas_first_initial_row_prop { \l_ropas_first_target_sp_int }
      }
      {
        \ropas_qp_distribute_group:nn {first}
          { \l_ropas_first_target_sp_int }
      }
    \bool_if:NTF \l_ropas_second_constraints_bool
      {
        \ropas_qp_initialise_feasible_group:nnn {second}
          \l_ropas_second_initial_row_prop { \l_ropas_second_target_sp_int }
      }
      {
        \ropas_qp_distribute_group:nn {second}
          { \l_ropas_second_target_sp_int }
      }
    \int_compare:nNnT { \l_ropas_numeric_rows_int } > {0}
      {
        \prop_get:NxN \g_ropas_data_prop { grid/#1/row-ratio } \l_tmpa_tl
        \clist_set:NV \l_ropas_ratios_clist \l_tmpa_tl
        \fp_zero:N \l_ropas_ratio_sum_fp
        \int_step_inline:nn { \seq_count:N \l_ropas_row_types_seq }
          {
            \str_if_eq:eeT
              { \seq_item:Nn \l_ropas_row_types_seq {##1} } { numeric }
              { \fp_add:Nn \l_ropas_ratio_sum_fp
                  { \clist_item:Nn \l_ropas_ratios_clist {##1} } }
          }
        \fp_zero:N \l_tmpa_fp
        \int_zero:N \l_tmpa_int
        \int_zero:N \l_tmpb_int
        \int_step_inline:nn { \seq_count:N \l_ropas_row_types_seq }
          {
            \str_if_eq:eeT
              { \seq_item:Nn \l_ropas_row_types_seq {##1} } { numeric }
              {
                \int_incr:N \l_tmpa_int
                \fp_add:Nn \l_tmpa_fp
                  { \clist_item:Nn \l_ropas_ratios_clist {##1} }
                \int_compare:nNnTF { \l_tmpa_int }
                  = { \l_ropas_numeric_rows_int }
                  { \int_set_eq:NN \l_ropas_tmpc_int \l_ropas_numeric_target_sp_int }
                  { \int_set:Nn \l_ropas_tmpc_int
                      { \fp_eval:n
                          { floor(\l_ropas_numeric_target_sp_int
                              * \l_tmpa_fp / \l_ropas_ratio_sum_fp) } } }
                \seq_set_item:Nnx \l_ropas_row_sp_seq {##1}
                  { \int_eval:n { \l_ropas_tmpc_int - \l_tmpb_int } }
                \int_set_eq:NN \l_tmpb_int \l_ropas_tmpc_int
              }
          }
      }
  }

\cs_new_protected:Npn \ropas_grid_measure_min:nn #1#2
  {
    \group_begin:
      \tl_set:Nx \l_ropas_grid_tl {#1}
      \ropas_grid_prepare_columns:nn {\l_ropas_grid_tl} {#2}
      \ropas_measure_grid_children:n {\l_ropas_grid_tl}
      \ropas_init_row_minima:n {\l_ropas_grid_tl}
      \int_zero:N \l_ropas_numeric_rows_int
      \seq_map_inline:Nn \l_ropas_row_types_seq
        {
          \str_if_eq:nnT {##1}{numeric}
            { \int_incr:N \l_ropas_numeric_rows_int }
        }
      \int_compare:nNnTF { \l_ropas_numeric_rows_int } > {0}
        {
          \ropas_compute_selected_minimum:nnN
            {\l_ropas_grid_tl}{nonnumeric} \l_ropas_selected_minimum_dim
          \ropas_numeric_minimum:n {\l_ropas_grid_tl}
          \dim_set:Nn \l_tmpa_dim
            {
              \l_ropas_selected_minimum_dim
              + \l_ropas_numeric_required_dim
            }
        }
        {
          \ropas_compute_selected_minimum:nnN {\l_ropas_grid_tl}{all}
            \l_ropas_selected_minimum_dim
          \dim_set_eq:NN \l_tmpa_dim \l_ropas_selected_minimum_dim
          \dim_zero:N \l_ropas_numeric_required_dim
        }
      \int_step_inline:nn { \seq_count:N \l_ropas_row_dims_seq }
        {
          \prop_get:NxN \l_ropas_selected_row_dim_prop {##1} \l_tmpa_tl
          \prop_gput:Nxx \g_ropas_data_prop
            { minimum/\l_ropas_grid_tl/row/##1 }
            { \l_tmpa_tl }
        }
      \prop_gput:Nxx \g_ropas_data_prop { minimum/\l_ropas_grid_tl/numeric }
        { \dim_use:N \l_ropas_numeric_required_dim }
      \dim_gset_eq:NN \g_ropas_return_dim \l_tmpa_dim
    \group_end:
  }

\cs_new_protected:Npn \ropas_grid_allocate_rows:nn #1#2
  {
    \group_begin:
      \dim_set:Nn \l_ropas_grid_height_dim {#2}
      \ropas_prepare_row_groups:nn {#1}{\l_ropas_grid_height_dim}
      \ropas_qp_build_objective:n {#1}
      \ropas_qp_initialise_gradient:
      \ropas_qp_optimise_group:n {first}
      \ropas_qp_optimise_group:n {second}
      \int_step_inline:nn { \seq_count:N \l_ropas_row_sp_seq }
        {
          \prop_gput:Nxx \g_ropas_data_prop { layout/#1/row/##1 }
            { \seq_item:Nn \l_ropas_row_sp_seq {##1} sp }
        }
      \prop_gput:Nxx \g_ropas_data_prop { layout/#1/height }
        { \dim_use:N \l_ropas_grid_height_dim }
    \group_end:
  }

\cs_new:Npn \ropas_picture_number:n #1
  { \dim_to_decimal_in_unit:nn { \dim_eval:n {#1} } { 1pt } }

\cs_new_protected:Npn \ropas_rounded_rectangle:nnn #1#2#3
  {
    \group_begin:
      \dim_set:Nn \l_tmpa_dim { \dim_min:nn {#3} { #1 / 2 } }
      \dim_set:Nn \l_tmpa_dim { \dim_min:nn { \l_tmpa_dim } { #2 / 2 } }
      \setlength\unitlength{1pt}
      \begin{picture}
        (\ropas_picture_number:n {#1},\ropas_picture_number:n {#2})
        \put(\ropas_picture_number:n {\l_tmpa_dim},0)
          { \rule{\dim_eval:n { #1 - 2\l_tmpa_dim }}{#2} }
        \put(0,\ropas_picture_number:n {\l_tmpa_dim})
          { \rule{#1}{\dim_eval:n { #2 - 2\l_tmpa_dim }} }
        \dim_compare:nNnT { \l_tmpa_dim } > {0pt}
          {
            \hbox_set:Nn \l_tmpa_box
              {
                \setlength\unitlength{1pt}
                \begin{picture}(1,1)
                  \put(0.5,0.5){\circle*{1}}
                \end{picture}
              }
            \hbox_set:Nn \l_tmpb_box
              { \resizebox{\dim_eval:n {2\l_tmpa_dim}}
                  {\dim_eval:n {2\l_tmpa_dim}}{\box_use:N \l_tmpa_box} }
            \put(0,0){\box_use:N \l_tmpb_box}
            \put(\ropas_picture_number:n { #1 - 2\l_tmpa_dim },0)
              {\box_use:N \l_tmpb_box}
            \put(0,\ropas_picture_number:n { #2 - 2\l_tmpa_dim })
              {\box_use:N \l_tmpb_box}
            \put(\ropas_picture_number:n { #1 - 2\l_tmpa_dim },
                 \ropas_picture_number:n { #2 - 2\l_tmpa_dim })
              {\box_use:N \l_tmpb_box}
          }
      \end{picture}
    \group_end:
  }

\cs_new_protected:Npn \ropas_aligned_column:nn #1#2
  {
    \vbox to #2
      {
        \str_case:VnF \l_ropas_align_tl
          {
            { top }    { \box_use:N #1 \vss }
            { centre } { \vss \box_use:N #1 \vss }
            { bottom } { \vss \box_use:N #1 }
          }
          { \box_use:N #1 \vss }
      }
  }

\box_new:N \l_ropas_flow_render_box

\cs_new_protected:Npn \ropas_build_cell_content:nnn #1#2#3
  {
    \ropas_load_style_from_child:n {#1}
    \prop_get:NxN \g_ropas_data_prop { child/#1/column-width } \l_tmpa_tl
    \box_set_eq:Nc \l_ropas_source_box { g_ropas_child_#1_content_box }
    \prop_get:NxN \g_ropas_data_prop { child/#1/content-min-height } \l_tmpb_tl
    \prop_get:NxN \g_ropas_data_prop { child/#1/title-height } \l_ropas_tmpc_tl
    \dim_set:Nn \l_ropas_cell_title_height_dim { \l_ropas_tmpc_tl }
    \dim_zero:N \l_ropas_cell_title_separator_dim
    \prop_get:NxN \g_ropas_data_prop { child/#1/title-present } \l_ropas_tmpc_tl
    \prop_get:NxN \g_ropas_data_prop { child/#1/body-present } \l_ropas_tmpd_tl
    \dim_set:Nn \l_ropas_footnote_height_dim
      { \box_ht:c {g_ropas_child_#1_footnote_box}
        + \box_dp:c {g_ropas_child_#1_footnote_box} }
    \dim_zero:N \l_ropas_footnote_separator_dim
    \dim_compare:nNnT {\l_ropas_footnote_height_dim} > {0pt}
      {\dim_set_eq:NN \l_ropas_footnote_separator_dim
        \l_ropas_paragraph_leading_dim}
    \dim_set:Nn \l_ropas_top_float_height_dim
      {\box_ht:c {g_ropas_child_#1_top_float_box}
       + \box_dp:c {g_ropas_child_#1_top_float_box}}
    \dim_set:Nn \l_ropas_bottom_float_height_dim
      {\box_ht:c {g_ropas_child_#1_bottom_float_box}
       + \box_dp:c {g_ropas_child_#1_bottom_float_box}}
    \str_if_eq:VnT \l_ropas_tmpc_tl { true }
      {
        \bool_set:Nn \l_tmpa_bool
          {
            \str_if_eq_p:Vn \l_ropas_tmpd_tl { true }
            || \dim_compare_p:nNn
                 {\l_ropas_top_float_height_dim} > {0pt}
            || \dim_compare_p:nNn
                 {\l_ropas_bottom_float_height_dim} > {0pt}
          }
        \bool_if:NT \l_tmpa_bool
          { \dim_set_eq:NN \l_ropas_cell_title_separator_dim
              \l_ropas_paragraph_leading_dim }
      }
    \dim_zero:N \l_ropas_top_float_separator_dim
    \dim_zero:N \l_ropas_bottom_float_separator_dim
    \str_if_eq:VnT \l_ropas_tmpd_tl {true}
      {
        \dim_compare:nNnT {\l_ropas_top_float_height_dim} > {0pt}
          {\dim_set_eq:NN \l_ropas_top_float_separator_dim
            \l_ropas_paragraph_leading_dim}
        \dim_compare:nNnT {\l_ropas_bottom_float_height_dim} > {0pt}
          {\dim_set_eq:NN \l_ropas_bottom_float_separator_dim
            \l_ropas_paragraph_leading_dim}
      }
    \dim_set:Nn \l_ropas_cell_body_height_dim
      {
        #3 - \l_ropas_cell_title_height_dim
        - \l_ropas_cell_title_separator_dim
        - \l_ropas_top_float_height_dim
        - \l_ropas_top_float_separator_dim
        - \l_ropas_bottom_float_height_dim
        - \l_ropas_bottom_float_separator_dim
        - \l_ropas_footnote_height_dim
        - \l_ropas_footnote_separator_dim
      }
    \dim_compare:nNnF { \l_ropas_cell_body_height_dim } > { 0pt }
      { \dim_zero:N \l_ropas_cell_body_height_dim }
    \bool_set:Nn \l_tmpa_bool
      { ! \dim_compare_p:nNn { \l_tmpb_tl } > {#3} }
    \bool_if:NF \l_tmpa_bool { \tl_set:Nn \l_ropas_align_tl { top } }
    \dim_zero:N \l_ropas_body_used_height_dim
    \int_step_inline:nn { \l_ropas_column_num_int }
      {
        \int_compare:nNnTF {##1} = { \l_ropas_column_num_int }
          { \box_set_eq_drop:NN \l_ropas_split_box \l_ropas_source_box }
          {
            \ropas_vbox_split_flexible:NNn \l_ropas_split_box
              \l_ropas_source_box { \l_ropas_cell_body_height_dim }
            % A split box has the requested height, not its natural height.
            \vbox_set:Nn \l_ropas_split_box
              { \vbox_unpack_drop:N \l_ropas_split_box }
          }
        \box_if_exist:cF {g_ropas_child_#1_column_##1_box}
          {\box_new:c {g_ropas_child_#1_column_##1_box}}
        \exp_args:Nc \box_set_eq_drop:NN
          {g_ropas_child_#1_column_##1_box} \l_ropas_split_box
        \dim_set:Nn \l_ropas_tmpc_dim
          {\box_ht:c {g_ropas_child_#1_column_##1_box}
           + \box_dp:c {g_ropas_child_#1_column_##1_box}}
        \dim_set:Nn \l_ropas_body_used_height_dim
          {\dim_max:nn {\l_ropas_body_used_height_dim}
            {\l_ropas_tmpc_dim}}
        \prop_gput:Nxx \g_ropas_data_prop
          {layout/child/#1/column/##1/content-height}
          {\dim_use:N \l_ropas_tmpc_dim}
      }
    \hbox_set:Nn \l_ropas_body_render_box
      {
        \int_step_inline:nn { \l_ropas_column_num_int }
          {
            \dim_set:Nn \l_ropas_tmpc_dim
              {\box_ht:c {g_ropas_child_#1_column_##1_box}
               + \box_dp:c {g_ropas_child_#1_column_##1_box}}
            \dim_zero:N \l_ropas_tmpd_dim
            \str_case:Vn \l_ropas_align_tl
              {
                { centre }
                  {
                    \dim_set:Nn \l_ropas_tmpd_dim
                      { ( \l_ropas_body_used_height_dim - \l_ropas_tmpc_dim ) / 2 }
                  }
                { bottom }
                  {
                    \dim_set:Nn \l_ropas_tmpd_dim
                      { \l_ropas_body_used_height_dim - \l_ropas_tmpc_dim }
                  }
              }
            \dim_compare:nNnF { \l_ropas_tmpd_dim } > { 0pt }
              { \dim_zero:N \l_ropas_tmpd_dim }
            \prop_gput:Nxx \g_ropas_data_prop
              { layout/child/#1/column/##1/top-offset }
              { \dim_use:N \l_ropas_tmpd_dim }
            \hbox to \l_tmpa_tl
              {
                \hss
                \exp_args:Nc \ropas_aligned_column:nn
                  {g_ropas_child_#1_column_##1_box}
                  {\l_ropas_body_used_height_dim}
                \hss
              }
            \int_compare:nNnF {##1} = { \l_ropas_column_num_int }
              { \hskip \l_ropas_column_gap_dim }
          }
      }
    \vbox_set:Nn \l_ropas_flow_render_box
      {
        \offinterlineskip
        \box_use:c {g_ropas_child_#1_top_float_box}
        \vskip \l_ropas_top_float_separator_dim
        \box_use:N \l_ropas_body_render_box
        \vskip \l_ropas_bottom_float_separator_dim
        \box_use:c {g_ropas_child_#1_bottom_float_box}
      }
    \dim_set:Nn \l_ropas_flow_available_height_dim
      {#3 - \l_ropas_cell_title_height_dim
       - \l_ropas_cell_title_separator_dim
       - \l_ropas_footnote_height_dim
       - \l_ropas_footnote_separator_dim}
    \dim_compare:nNnF {\l_ropas_flow_available_height_dim} > {0pt}
      {\dim_zero:N \l_ropas_flow_available_height_dim}
    \dim_compare:nNnT
      {\box_ht:N \l_ropas_flow_render_box
       + \box_dp:N \l_ropas_flow_render_box}
      > {\l_ropas_flow_available_height_dim}
      {\tl_set:Nn \l_ropas_align_tl {top}}
    \hbox_set:Nn \l_ropas_render_box
      {
        \vbox to #3
          {
            \offinterlineskip
            \str_if_eq:VnT \l_ropas_tmpc_tl { true }
              {
                \box_use:c { g_ropas_child_#1_title_box }
                \vskip \l_ropas_cell_title_separator_dim
              }
            \dim_compare:nNnTF
              {\box_ht:N \l_ropas_flow_render_box
               + \box_dp:N \l_ropas_flow_render_box}
              > {\l_ropas_flow_available_height_dim}
              {\box_use:N \l_ropas_flow_render_box}
              {
                \vbox to \l_ropas_flow_available_height_dim
                  {
                    \str_case:Vn \l_ropas_align_tl
                      {{centre}{\vss}{bottom}{\vss}}
                    \box_use:N \l_ropas_flow_render_box
                    \str_case:Vn \l_ropas_align_tl
                      {{top}{\vss}{centre}{\vss}}
                  }
              }
            \vskip \l_ropas_footnote_separator_dim
            \box_use:c {g_ropas_child_#1_footnote_box}
            \vss
          }
      }
    \prop_gput:Nxx \g_ropas_data_prop { layout/child/#1/title-height }
      { \dim_use:N \l_ropas_cell_title_height_dim }
    \prop_get:NxN \g_ropas_data_prop { child/#1/title-width } \l_tmpa_tl
    \prop_gput:NxV \g_ropas_data_prop { layout/child/#1/title-width }
      \l_tmpa_tl
    \prop_gput:Nxx \g_ropas_data_prop { layout/child/#1/title-separator }
      { \dim_use:N \l_ropas_cell_title_separator_dim }
    \prop_gput:Nxx \g_ropas_data_prop { layout/child/#1/body-height }
      { \dim_use:N \l_ropas_cell_body_height_dim }
    \prop_gput:Nnn \g_ropas_data_prop { layout/child/#1/title-top-offset }
      { 0pt }
  }

\cs_new_protected:Npn \ropas_build_cell:nnn #1#2#3
  {
    \group_begin:
      \dim_set:Nn \l_ropas_cell_width_dim {#2}
      \dim_set:Nn \l_ropas_cell_height_dim {#3}
      \ropas_load_style_from_child:n {#1}
      \ropas_block_side_separations:n {#1}
      \dim_set:Nn \l_ropas_cell_background_width_dim
        { \l_ropas_cell_width_dim
          - \l_ropas_sep_left_dim - \l_ropas_sep_right_dim }
      \dim_set:Nn \l_ropas_cell_background_height_dim
        { \l_ropas_cell_height_dim
          - \l_ropas_sep_top_dim - \l_ropas_sep_bottom_dim }
      \dim_set:Nn \l_ropas_cell_inner_height_dim
        { \l_ropas_cell_background_height_dim - 2\l_ropas_margin_dim }
      \dim_compare:nNnF { \l_ropas_cell_background_width_dim } > {0pt}
        { \dim_zero:N \l_ropas_cell_background_width_dim }
      \dim_compare:nNnF { \l_ropas_cell_background_height_dim } > {0pt}
        { \dim_zero:N \l_ropas_cell_background_height_dim }
      \dim_compare:nNnF { \l_ropas_cell_inner_height_dim } > {0pt}
        { \dim_zero:N \l_ropas_cell_inner_height_dim }
      \ropas_build_cell_content:nnn {#1}
        { \dim_eval:n
            { \l_ropas_cell_background_width_dim - 2\l_ropas_margin_dim } }
        { \l_ropas_cell_inner_height_dim }
      \dim_set:Nn \l_ropas_cell_background_offset_dim
        { \l_ropas_sep_left_dim }
      \dim_set:Nn \l_ropas_cell_background_y_offset_dim
        { \l_ropas_sep_bottom_dim }
      \dim_set:Nn \l_ropas_cell_content_offset_dim
        { \l_ropas_cell_background_offset_dim + \l_ropas_margin_dim }
      \dim_set:Nn \l_ropas_cell_content_y_offset_dim
        { \l_ropas_cell_background_y_offset_dim + \l_ropas_margin_dim }
      \prop_gput:Nxx \g_ropas_data_prop { layout/child/#1/background-offset }
        { \dim_use:N \l_ropas_cell_background_offset_dim }
      \prop_gput:Nxx \g_ropas_data_prop { layout/child/#1/content-offset }
        { \dim_use:N \l_ropas_cell_content_offset_dim }
      \prop_gput:Nxx \g_ropas_data_prop { layout/child/#1/content-width }
        { \dim_eval:n
            { \l_ropas_cell_background_width_dim - 2\l_ropas_margin_dim } }
      \prop_gput:Nxx \g_ropas_data_prop { layout/child/#1/content-height }
        { \dim_use:N \l_ropas_cell_inner_height_dim }
      \hbox_gset:cn { g_ropas_child_#1_render_box }
        {
          \setlength\unitlength{1pt}
          \begin{picture}
            (\ropas_picture_number:n {\l_ropas_cell_width_dim},
             \ropas_picture_number:n {\l_ropas_cell_height_dim})
            \put(\ropas_picture_number:n
                    { \l_ropas_cell_background_offset_dim },
                 \ropas_picture_number:n
                    { \l_ropas_cell_background_y_offset_dim })
              {
                \makebox(0,0)[lb]
                  { \color{\l_ropas_colour_tl}
                    \ropas_rounded_rectangle:nnn
                      {\l_ropas_cell_background_width_dim}
                      {\l_ropas_cell_background_height_dim}
                      {\l_ropas_corner_radius_dim} }
              }
            \put(\ropas_picture_number:n { \l_ropas_cell_content_offset_dim },
                 \ropas_picture_number:n
                   { \l_ropas_cell_content_y_offset_dim })
              { \makebox(0,0)[lb]{\box_use:N \l_ropas_render_box} }
          \end{picture}
        }
    \group_end:
  }

\cs_new_protected:Npn \ropas_build_grid_block:nnn #1#2#3
  {
    \group_begin:
      \dim_set:Nn \l_ropas_cell_width_dim {#2}
      \dim_set:Nn \l_ropas_cell_height_dim {#3}
      \ropas_load_style_from_child:n {#1}
      \ropas_block_side_separations:n {#1}
      \dim_set:Nn \l_ropas_cell_background_width_dim
        { \l_ropas_cell_width_dim
          - \l_ropas_sep_left_dim - \l_ropas_sep_right_dim }
      \dim_set:Nn \l_ropas_cell_background_height_dim
        { \l_ropas_cell_height_dim
          - \l_ropas_sep_top_dim - \l_ropas_sep_bottom_dim }
      \dim_set:Nn \l_ropas_cell_inner_height_dim
        { \l_ropas_cell_background_height_dim - 2\l_ropas_margin_dim }
      \dim_set:Nn \l_tmpa_dim
        { \l_ropas_cell_background_width_dim - 2\l_ropas_margin_dim }
      \dim_compare:nNnF {\l_tmpa_dim} > {0pt}
        { \dim_set:Nn \l_tmpa_dim {1pt} }
      \dim_compare:nNnF {\l_ropas_cell_inner_height_dim} > {0pt}
        { \dim_zero:N \l_ropas_cell_inner_height_dim }
      \prop_get:NxN \g_ropas_data_prop { child/#1/title-present } \l_tmpb_tl
      \dim_zero:N \l_ropas_cell_title_height_dim
      \dim_zero:N \l_ropas_cell_title_separator_dim
      \str_if_eq:VnT \l_tmpb_tl { true }
        {
          \prop_get:NxN \g_ropas_data_prop { child/#1/title-height }
            \l_ropas_tmpc_tl
          \dim_set:Nn \l_ropas_cell_title_height_dim {\l_ropas_tmpc_tl}
          \dim_set_eq:NN \l_ropas_cell_title_separator_dim
            \l_ropas_paragraph_leading_dim
        }
      \dim_set:Nn \l_ropas_cell_body_height_dim
        {
          \l_ropas_cell_inner_height_dim
          - \l_ropas_cell_title_height_dim
          - \l_ropas_cell_title_separator_dim
        }
      \dim_compare:nNnF {\l_ropas_cell_body_height_dim} > {0pt}
        { \dim_zero:N \l_ropas_cell_body_height_dim }
      \prop_get:NxN \g_ropas_data_prop { child/#1/grid } \l_ropas_tmpc_tl
      \ropas_grid_render:nnn {\l_ropas_tmpc_tl}{\l_tmpa_dim}
        {\l_ropas_cell_body_height_dim}
      \vbox_set:Nn \l_ropas_render_box
        {
          \offinterlineskip
          \str_if_eq:VnT \l_tmpb_tl { true }
            {
              \box_use:c { g_ropas_child_#1_title_box }
              \vskip \l_ropas_cell_title_separator_dim
            }
          \nointerlineskip
          \box_use:c { g_ropas_grid_\l_ropas_tmpc_tl _render_box }
        }
      \dim_set:Nn \l_ropas_cell_background_offset_dim
        { \l_ropas_sep_left_dim }
      \dim_set:Nn \l_ropas_cell_background_y_offset_dim
        { \l_ropas_sep_bottom_dim }
      \dim_set:Nn \l_ropas_cell_content_offset_dim
        { \l_ropas_cell_background_offset_dim + \l_ropas_margin_dim }
      \dim_set:Nn \l_ropas_cell_content_y_offset_dim
        { \l_ropas_cell_background_y_offset_dim + \l_ropas_margin_dim }
      \prop_gput:Nxx \g_ropas_data_prop { layout/child/#1/background-offset }
        { \dim_use:N \l_ropas_cell_background_offset_dim }
      \prop_gput:Nxx \g_ropas_data_prop { layout/child/#1/content-offset }
        { \dim_use:N \l_ropas_cell_content_offset_dim }
      \prop_gput:Nxx \g_ropas_data_prop { layout/child/#1/content-width }
        { \dim_use:N \l_tmpa_dim }
      \prop_gput:Nxx \g_ropas_data_prop { layout/child/#1/content-height }
        { \dim_use:N \l_ropas_cell_inner_height_dim }
      \prop_gput:Nxx \g_ropas_data_prop { layout/child/#1/title-height }
        { \dim_use:N \l_ropas_cell_title_height_dim }
      \prop_gput:Nxx \g_ropas_data_prop { layout/child/#1/title-separator }
        { \dim_use:N \l_ropas_cell_title_separator_dim }
      \prop_gput:Nxx \g_ropas_data_prop { layout/child/#1/body-height }
        { \dim_use:N \l_ropas_cell_body_height_dim }
      \hbox_gset:cn { g_ropas_child_#1_render_box }
        {
          \setlength\unitlength{1pt}
          \begin{picture}
            (\ropas_picture_number:n {\l_ropas_cell_width_dim},
             \ropas_picture_number:n {\l_ropas_cell_height_dim})
            \put(\ropas_picture_number:n {\l_ropas_cell_background_offset_dim},
                 \ropas_picture_number:n
                   {\l_ropas_cell_background_y_offset_dim})
              {
                \makebox(0,0)[lb]
                  { \color{\l_ropas_colour_tl}
                    \ropas_rounded_rectangle:nnn
                      {\l_ropas_cell_background_width_dim}
                      {\l_ropas_cell_background_height_dim}
                      {\l_ropas_corner_radius_dim} }
              }
            \put(\ropas_picture_number:n {\l_ropas_cell_content_offset_dim},
                 \ropas_picture_number:n
                   {\l_ropas_cell_content_y_offset_dim})
              { \makebox(0,0)[lb]{\box_use:N \l_ropas_render_box} }
          \end{picture}
        }
    \group_end:
  }

\cs_new_protected:Npn \ropas_child_geometry:nnNNNN #1#2#3#4#5#6
  {
    \prop_get:NxN \g_ropas_data_prop { child/#2/row-start } \l_tmpa_tl
    \prop_get:NxN \g_ropas_data_prop { child/#2/row-end } \l_tmpb_tl
    \prop_get:NxN \g_ropas_data_prop { child/#2/col-start } \l_ropas_tmpc_tl
    \prop_get:NxN \g_ropas_data_prop { child/#2/col-end } \l_ropas_tmpd_tl
    \dim_zero:N #3
    \int_step_inline:nn { \l_ropas_tmpc_tl - 1 }
      { \prop_get:NxN \g_ropas_data_prop { layout/#1/col/##1 } \l_ropas_child_tl
        \dim_add:Nn #3 { \l_ropas_child_tl } }
    \dim_zero:N #5
    \int_step_inline:nnn { \l_ropas_tmpc_tl } { \l_ropas_tmpd_tl }
      { \prop_get:NxN \g_ropas_data_prop { layout/#1/col/##1 } \l_ropas_child_tl
        \dim_add:Nn #5 { \l_ropas_child_tl } }
    \dim_zero:N #6
    \int_step_inline:nnn { \l_tmpa_tl } { \l_tmpb_tl }
      { \prop_get:NxN \g_ropas_data_prop { layout/#1/row/##1 } \l_ropas_child_tl
        \dim_add:Nn #6 { \l_ropas_child_tl } }
    \prop_get:NxN \g_ropas_data_prop { layout/#1/height } \l_ropas_child_tl
    \dim_set:Nn #4 { \l_ropas_child_tl }
    \int_step_inline:nn { \l_tmpb_tl }
      { \prop_get:NxN \g_ropas_data_prop { layout/#1/row/##1 } \l_ropas_child_tl
        \dim_sub:Nn #4 { \l_ropas_child_tl } }
  }

\cs_new_protected:Npn \ropas_emit_cell_info:nn #1#2
  {
    \prop_get:NxN \g_ropas_data_prop { child/#1/min-height } \l_tmpa_tl
    \prop_get:NxN \g_ropas_data_prop { child/#1/h-overflow } \l_tmpb_tl
    \bool_set:Nn \l_tmpa_bool
      { \dim_compare_p:nNn { \l_tmpa_tl } > {#2} }
    \str_if_eq:VnT \l_tmpb_tl { true } { \bool_set_true:N \l_tmpa_bool }
    \bool_if:NT \l_tmpa_bool
      {
        \prop_get:NxN \g_ropas_data_prop { child/#1/row-start } \l_tmpa_tl
        \prop_get:NxN \g_ropas_data_prop { child/#1/row-end } \l_tmpb_tl
        \prop_get:NxN \g_ropas_data_prop { child/#1/col-start } \l_ropas_tmpc_tl
        \prop_get:NxN \g_ropas_data_prop { child/#1/col-end } \l_ropas_tmpd_tl
        \ropas_class_info:n
          { Content~does~not~fit~in~posterblock~rows~\l_tmpa_tl--\l_tmpb_tl,
            ~columns~\l_ropas_tmpc_tl--\l_ropas_tmpd_tl;~it~is~allowed~to~overflow }
      }
  }

\cs_new_protected:Npn \ropas_grid_render:nnn #1#2#3
  {
    \group_begin:
      \tl_set:Nx \l_ropas_grid_tl {#1}
      \dim_set:Nn \l_ropas_grid_width_dim {#2}
      \dim_set:Nn \l_ropas_grid_height_dim {#3}
      \ropas_grid_allocate_rows:nn
        {\l_ropas_grid_tl} {\l_ropas_grid_height_dim}
      \hbox_gset:cn { g_ropas_grid_\l_ropas_grid_tl _render_box }
        {
          \setlength\unitlength{1pt}
          \begin{picture}
            (\ropas_picture_number:n {\l_ropas_grid_width_dim},
             \ropas_picture_number:n {\l_ropas_grid_height_dim})
            \prop_get:NxN \g_ropas_data_prop
              { grid/\l_ropas_grid_tl/children } \l_tmpa_tl
            \clist_set:NV \l_ropas_children_clist \l_tmpa_tl
            \clist_map_inline:Nn \l_ropas_children_clist
              {
                \ropas_child_geometry:nnNNNN {\l_ropas_grid_tl}{##1}
                  \l_tmpa_dim\l_tmpb_dim\l_ropas_tmpc_dim\l_ropas_tmpd_dim
                \prop_gput:Nxx \g_ropas_data_prop { layout/child/##1/x }
                  { \dim_use:N \l_tmpa_dim }
                \prop_gput:Nxx \g_ropas_data_prop { layout/child/##1/y }
                  { \dim_use:N \l_tmpb_dim }
                \prop_gput:Nxx \g_ropas_data_prop { layout/child/##1/width }
                  { \dim_use:N \l_ropas_tmpc_dim }
                \prop_gput:Nxx \g_ropas_data_prop { layout/child/##1/height }
                  { \dim_use:N \l_ropas_tmpd_dim }
                \prop_get:NxN \g_ropas_data_prop { child/##1/type } \l_tmpa_tl
                \str_case:VnF \l_tmpa_tl
                  {
                    { block }
                      {
                        \ropas_build_cell:nnn
                          {##1}{\l_ropas_tmpc_dim}{\l_ropas_tmpd_dim}
                        \ropas_emit_cell_info:nn {##1}{\l_ropas_tmpd_dim}
                        \put(\ropas_picture_number:n {\l_tmpa_dim},
                             \ropas_picture_number:n {\l_tmpb_dim})
                          { \makebox(0,0)[lb]
                              { \box_use:c
                                  { g_ropas_child_##1_render_box } } }
                      }
                    { grid-block }
                      {
                        \ropas_build_grid_block:nnn
                          {##1}{\l_ropas_tmpc_dim}{\l_ropas_tmpd_dim}
                        \ropas_emit_cell_info:nn {##1}{\l_ropas_tmpd_dim}
                        \put(\ropas_picture_number:n {\l_tmpa_dim},
                             \ropas_picture_number:n {\l_tmpb_dim})
                          { \makebox(0,0)[lb]
                              { \box_use:c
                                  { g_ropas_child_##1_render_box } } }
                      }
                    { subgrid }
                      {
                        \prop_get:NxN \g_ropas_data_prop { child/##1/grid }
                          \l_tmpb_tl
                        \ropas_grid_render:nnn {\l_tmpb_tl}
                          {\l_ropas_tmpc_dim}{\l_ropas_tmpd_dim}
                        \put(\ropas_picture_number:n {\l_tmpa_dim},
                             \ropas_picture_number:n {\l_tmpb_dim})
                          { \makebox(0,0)[lb]
                              { \box_use:c
                                  { g_ropas_grid_\l_tmpb_tl _render_box } } }
                      }
                    { empty-subgrid } { }
                  }
                  { }
              }
            \ropas_draw_grid_lines:nnn {\l_ropas_grid_tl}
              {\l_ropas_grid_width_dim}{\l_ropas_grid_height_dim}
          \end{picture}
        }
    \group_end:
  }

\cs_new_protected:Npn \ropas_draw_grid_lines:nnn #1#2#3
  {
    \prop_get:NxN \g_ropas_data_prop { grid/#1/line-width } \l_tmpa_tl
    \dim_compare:nNnT { \l_tmpa_tl } > {0pt}
      {
        \prop_get:NxN \g_ropas_data_prop { grid/#1/line-colour } \l_tmpb_tl
        \color{\l_tmpb_tl}
        % Draw only boundaries which actually separate two immediate children.
        % In particular, a track boundary hidden inside a spanning child must
        % not cut through that child.
        \prop_get:NxN \g_ropas_data_prop { grid/#1/cols } \l_ropas_tmpc_tl
        \dim_zero:N \l_tmpa_dim
        \int_step_inline:nn { \l_ropas_tmpc_tl - 1 }
          {
            \prop_get:NxN \g_ropas_data_prop { layout/#1/col/##1 }
              \l_ropas_tmpd_tl
            \dim_add:Nn \l_tmpa_dim { \l_ropas_tmpd_tl }
            \prop_get:NxN \g_ropas_data_prop { grid/#1/rows } \l_ropas_tmpd_tl
            \dim_set:Nn \l_tmpb_dim {#3}
            \int_step_inline:nn { \l_ropas_tmpd_tl }
              {
                \prop_get:NxN \g_ropas_data_prop { layout/#1/row/####1 }
                  \l_ropas_child_tl
                \dim_sub:Nn \l_tmpb_dim { \l_ropas_child_tl }
                \prop_get:NxNTF \g_ropas_data_prop
                  { occupied/#1/####1/##1 } \l_ropas_tmpc_tl
                  {
                    \prop_get:NxNTF \g_ropas_data_prop
                      { occupied/#1/####1/\int_eval:n { ##1 + 1 } } \l_ropas_tmpd_tl
                      {
                        \tl_if_eq:NNTF \l_ropas_tmpc_tl \l_ropas_tmpd_tl
                          { }
                          {
                            \put
                              (\ropas_picture_number:n
                                  { \l_tmpa_dim - \l_tmpa_tl/2 },
                               \ropas_picture_number:n { \l_tmpb_dim })
                              { \rule{\l_tmpa_tl}{\l_ropas_child_tl} }
                          }
                      }
                      { }
                  }
                  { }
              }
          }
        \prop_get:NxN \g_ropas_data_prop { grid/#1/rows } \l_ropas_tmpc_tl
        \dim_set:Nn \l_tmpa_dim {#3}
        \int_step_inline:nn { \l_ropas_tmpc_tl - 1 }
          {
            \prop_get:NxN \g_ropas_data_prop { layout/#1/row/##1 }
              \l_ropas_tmpd_tl
            \dim_sub:Nn \l_tmpa_dim { \l_ropas_tmpd_tl }
            \prop_get:NxN \g_ropas_data_prop { grid/#1/cols } \l_ropas_tmpd_tl
            \dim_zero:N \l_tmpb_dim
            \int_step_inline:nn { \l_ropas_tmpd_tl }
              {
                \prop_get:NxN \g_ropas_data_prop { layout/#1/col/####1 }
                  \l_ropas_child_tl
                \prop_get:NxNTF \g_ropas_data_prop
                  { occupied/#1/##1/####1 } \l_ropas_tmpc_tl
                  {
                    \prop_get:NxNTF \g_ropas_data_prop
                      { occupied/#1/\int_eval:n { ##1 + 1 }/####1 } \l_ropas_tmpd_tl
                      {
                        \tl_if_eq:NNTF \l_ropas_tmpc_tl \l_ropas_tmpd_tl
                          { }
                          {
                            \put
                              (\ropas_picture_number:n { \l_tmpb_dim },
                               \ropas_picture_number:n
                                 { \l_tmpa_dim - \l_tmpa_tl/2 })
                              { \rule{\l_ropas_child_tl}{\l_tmpa_tl} }
                          }
                      }
                      { }
                  }
                  { }
                \dim_add:Nn \l_tmpb_dim { \l_ropas_child_tl }
              }
          }
      }
  }

% --------------------------------------------------------------------------
% Header, logos, and the one-page document frame
% --------------------------------------------------------------------------

\box_new:N \g_ropas_header_box
\box_new:N \g_ropas_logo_box
\box_new:N \l_ropas_header_inner_box
\bool_new:N \l_ropas_first_header_item_bool
\seq_new:N \g_ropas_logo_widths_seq
\int_new:N \g_ropas_logo_lines_int
\int_new:N \l_ropas_logo_line_count_int
\dim_new:N \g_ropas_body_width_dim
\dim_new:N \g_ropas_body_height_dim
\tl_new:N \l_ropas_context_tl
\int_new:N \g_ropas_top_grid_count_int
\bool_new:N \g_ropas_grid_output_bool
\bool_new:N \g_ropas_page_started_bool
\box_new:N \g_ropas_background_box
\box_new:N \g_ropas_document_body_box
\box_new:c {g_ropas_child_document_top_float_box}
\box_new:c {g_ropas_child_document_bottom_float_box}
\box_new:N \g_ropas_document_title_box
\dim_new:N \g_ropas_document_title_reserve_dim
\bool_new:N \l_ropas_document_title_seen_bool
\bool_new:N \l_ropas_document_content_seen_bool
\bool_new:N \g_ropas_document_content_seen_bool

\cs_new_protected:Npn \ropas_header_item:NNNn #1#2#3#4
  {
    \tl_if_blank:VF #3
      {
        \bool_if:NF \l_ropas_first_header_item_bool
          { \vskip \g_ropas_header_leading_dim }
        \bool_set_false:N \l_ropas_first_header_item_bool
        % The explicit header leading is the complete space between items.
        % Suppress TeX's additional interline glue before the first line of
        % each item; later lines within the same item retain their baseline
        % leading.
        \nointerlineskip
        \group_begin:
          \sffamily
          #4
          \ropas_set_size_base:nn
            {#1}{ \dim_eval:n { #1 + \g_ropas_header_leading_dim } }
          \fontsize{#1}
            { \dim_eval:n { #1 + \g_ropas_header_leading_dim } }
          \selectfont
          \color{#2}
          \centering
          \tl_use:N #3
          \par
        \group_end:
      }
  }

\cs_new_protected:Npn \ropas_build_header:
  {
    \dim_set:Nn \l_tmpa_dim
      { \g_ropas_paper_width_dim - 2\g_ropas_body_side_dim }
    \dim_compare:nNnF { \l_tmpa_dim } > {0pt}
      { \ropas_class_error:nn { Body~side~margins~consume~the~paper~width }
          { Reduce~the~body~side~margin. }
        \dim_set:Nn \l_tmpa_dim {1pt} }
    \vbox_set:Nn \l_ropas_header_inner_box
      {
        \hsize=\l_tmpa_dim
        \linewidth=\hsize
        \parindent=0pt
        \parskip=0pt
        \lineskip=1pt
        \lineskiplimit=0pt
        \vskip \g_ropas_header_top_dim
        \bool_set_true:N \l_ropas_first_header_item_bool
        \ropas_header_item:NNNn \g_ropas_title_size_dim
          \g_ropas_title_colour_tl \g_ropas_title_tl { \bfseries }
        \ropas_header_item:NNNn \g_ropas_subtitle_size_dim
          \g_ropas_subtitle_colour_tl \g_ropas_subtitle_tl { \bfseries }
        \ropas_header_item:NNNn \g_ropas_author_size_dim
          \g_ropas_author_colour_tl \g_ropas_author_tl { }
        \ropas_header_item:NNNn \g_ropas_institute_size_dim
          \g_ropas_institute_colour_tl \g_ropas_institute_tl { }
        \vskip \g_ropas_header_bottom_dim
        \nointerlineskip
        \hbox to \l_tmpa_dim { \hfil }
      }
    \hbox_gset:Nn \g_ropas_header_box
      { \hbox to \g_ropas_paper_width_dim
          { \hskip \g_ropas_body_side_dim
            \box_use:N \l_ropas_header_inner_box
            \hskip \g_ropas_body_side_dim } }
    \dim_gset:Nn \g_ropas_header_height_dim
      { \box_ht:N \g_ropas_header_box + \box_dp:N \g_ropas_header_box }
  }

\cs_new_protected:Npn \ropas_measure_logos:
  {
    \seq_gclear:N \g_ropas_logo_widths_seq
    \seq_map_indexed_inline:Nn \g_ropas_logos_seq
      {
        \box_if_exist:cF { g_ropas_logo_##1_box }
          { \box_new:c { g_ropas_logo_##1_box } }
        \hbox_gset:cn { g_ropas_logo_##1_box }
          { \includegraphics[height=\g_ropas_logo_height_dim]{##2} }
        \seq_gput_right:Nx \g_ropas_logo_widths_seq
          { \dim_eval:n { \box_wd:c { g_ropas_logo_##1_box } } }
      }
  }

\prop_new:N \l_ropas_logo_dp_over_prop
\prop_new:N \l_ropas_logo_dp_lines_prop
\prop_new:N \l_ropas_logo_dp_squares_prop
\prop_new:N \l_ropas_logo_dp_previous_prop
\int_new:N \l_ropas_logo_start_int
\int_new:N \l_ropas_logo_end_int
\int_new:N \l_ropas_logo_cursor_int
\int_new:N \l_ropas_logo_segment_count_int
\int_new:N \l_ropas_logo_segment_out_int
\int_new:N \l_ropas_logo_candidate_out_int
\int_new:N \l_ropas_logo_candidate_lines_int
\fp_new:N \l_ropas_logo_slot_fp
\fp_new:N \l_ropas_logo_width_sum_fp
\fp_new:N \l_ropas_logo_center_fp
\fp_new:N \l_ropas_logo_candidate_squares_fp
\bool_new:N \l_ropas_logo_segment_valid_bool
\bool_new:N \l_ropas_logo_candidate_better_bool

\prg_new_protected_conditional:Npnn \ropas_logo_segment_valid:nn #1#2 { TF }
  {
    \int_set:Nn \l_ropas_logo_segment_count_int {#2-#1+1}
    \fp_set:Nn \l_ropas_logo_slot_fp
      {\dim_to_decimal_in_sp:n {\g_ropas_body_width_dim}
       / \l_ropas_logo_segment_count_int}
    \bool_set_true:N \l_ropas_logo_segment_valid_bool
    \int_step_inline:nnn {#1} {#2-1}
      {
        \fp_compare:nNnT
          {(\dim_to_decimal_in_sp:n
              {\seq_item:Nn \g_ropas_logo_widths_seq {##1}}
            + \dim_to_decimal_in_sp:n
              {\seq_item:Nn \g_ropas_logo_widths_seq {##1+1}})/2}
          > {\l_ropas_logo_slot_fp}
          {\bool_set_false:N \l_ropas_logo_segment_valid_bool}
      }
    \bool_if:NTF \l_ropas_logo_segment_valid_bool
      {\prg_return_true:} {\prg_return_false:}
  }

\cs_new_protected:Npn \ropas_logo_segment_metrics:nn #1#2
  {
    \int_zero:N \l_ropas_logo_segment_out_int
    \fp_zero:N \l_ropas_logo_width_sum_fp
    \int_step_inline:nnn {#1} {#2}
      {
        \fp_set:Nn \l_tmpa_fp
          {\dim_to_decimal_in_sp:n
            {\seq_item:Nn \g_ropas_logo_widths_seq {##1}}}
        \fp_add:Nn \l_ropas_logo_width_sum_fp {\l_tmpa_fp}
        \fp_set:Nn \l_ropas_logo_center_fp
          {(##1-#1+0.5)*\l_ropas_logo_slot_fp}
        \bool_if:nT
          {
            \fp_compare_p:nNn
              {\l_ropas_logo_center_fp-\l_tmpa_fp/2} < {0}
            ||
            \fp_compare_p:nNn
              {\l_ropas_logo_center_fp+\l_tmpa_fp/2}
              > {\dim_to_decimal_in_sp:n {\g_ropas_body_width_dim}}
          }
          {\int_incr:N \l_ropas_logo_segment_out_int}
      }
  }

\cs_new_protected:Npn \ropas_logo_choose_optimal_partition:
  {
    \prop_clear:N \l_ropas_logo_dp_over_prop
    \prop_clear:N \l_ropas_logo_dp_lines_prop
    \prop_clear:N \l_ropas_logo_dp_squares_prop
    \prop_clear:N \l_ropas_logo_dp_previous_prop
    \int_step_inline:nn {\seq_count:N \g_ropas_logos_seq}
      {
        \int_set:Nn \l_ropas_logo_end_int {##1}
        \int_step_inline:nn {\l_ropas_logo_end_int}
          {
            \int_set:Nn \l_ropas_logo_start_int {####1}
            \ropas_logo_segment_valid:nnTF
              {\l_ropas_logo_start_int}{\l_ropas_logo_end_int}
              {
                \ropas_logo_segment_metrics:nn
                  {\l_ropas_logo_start_int}{\l_ropas_logo_end_int}
                \int_set_eq:NN \l_ropas_logo_candidate_out_int
                  \l_ropas_logo_segment_out_int
                \int_set:Nn \l_ropas_logo_candidate_lines_int {1}
                \fp_set:Nn \l_ropas_logo_candidate_squares_fp
                  {\l_ropas_logo_width_sum_fp^2}
                \int_compare:nNnT {\l_ropas_logo_start_int} > {1}
                  {
                    \int_set:Nn \l_tmpa_int
                      {\l_ropas_logo_start_int-1}
                    \prop_get:NxN \l_ropas_logo_dp_over_prop
                      {\int_use:N \l_tmpa_int} \l_tmpa_tl
                    \prop_get:NxN \l_ropas_logo_dp_lines_prop
                      {\int_use:N \l_tmpa_int} \l_tmpb_tl
                    \prop_get:NxN \l_ropas_logo_dp_squares_prop
                      {\int_use:N \l_tmpa_int} \l_ropas_tmpc_tl
                    \int_add:Nn \l_ropas_logo_candidate_out_int
                      {\l_tmpa_tl}
                    \int_add:Nn \l_ropas_logo_candidate_lines_int
                      {\l_tmpb_tl}
                    \fp_add:Nn \l_ropas_logo_candidate_squares_fp
                      {\l_ropas_tmpc_tl}
                  }
                \bool_set_false:N \l_ropas_logo_candidate_better_bool
                \prop_get:NxNTF \l_ropas_logo_dp_over_prop
                  {\int_use:N \l_ropas_logo_end_int} \l_tmpa_tl
                  {
                    \int_compare:nNnTF
                      {\l_ropas_logo_candidate_out_int} < {\l_tmpa_tl}
                      {\bool_set_true:N \l_ropas_logo_candidate_better_bool}
                      {
                        \int_compare:nNnT
                          {\l_ropas_logo_candidate_out_int} = {\l_tmpa_tl}
                          {
                            \prop_get:NxN \l_ropas_logo_dp_lines_prop
                              {\int_use:N \l_ropas_logo_end_int} \l_tmpb_tl
                            \int_compare:nNnTF
                              {\l_ropas_logo_candidate_lines_int}
                              < {\l_tmpb_tl}
                              {\bool_set_true:N
                                \l_ropas_logo_candidate_better_bool}
                              {
                                \int_compare:nNnT
                                  {\l_ropas_logo_candidate_lines_int}
                                  = {\l_tmpb_tl}
                                  {
                                    \prop_get:NxN
                                      \l_ropas_logo_dp_squares_prop
                                      {\int_use:N \l_ropas_logo_end_int}
                                      \l_ropas_tmpc_tl
                                    \fp_compare:nNnT
                                      {\l_ropas_logo_candidate_squares_fp}
                                      < {\l_ropas_tmpc_tl}
                                      {\bool_set_true:N
                                        \l_ropas_logo_candidate_better_bool}
                                  }
                              }
                          }
                      }
                  }
                  {\bool_set_true:N \l_ropas_logo_candidate_better_bool}
                \bool_if:NT \l_ropas_logo_candidate_better_bool
                  {
                    \prop_put:Nxx \l_ropas_logo_dp_over_prop
                      {\int_use:N \l_ropas_logo_end_int}
                      {\int_use:N \l_ropas_logo_candidate_out_int}
                    \prop_put:Nxx \l_ropas_logo_dp_lines_prop
                      {\int_use:N \l_ropas_logo_end_int}
                      {\int_use:N \l_ropas_logo_candidate_lines_int}
                    \prop_put:Nxx \l_ropas_logo_dp_squares_prop
                      {\int_use:N \l_ropas_logo_end_int}
                      {\fp_use:N \l_ropas_logo_candidate_squares_fp}
                    \prop_put:Nxx \l_ropas_logo_dp_previous_prop
                      {\int_use:N \l_ropas_logo_end_int}
                      {\int_eval:n {\l_ropas_logo_start_int-1}}
                  }
              }
              { }
          }
      }
    \int_set:Nn \l_ropas_logo_cursor_int
      {\seq_count:N \g_ropas_logos_seq}
    \prop_get:NxN \l_ropas_logo_dp_lines_prop
      {\int_use:N \l_ropas_logo_cursor_int} \l_tmpa_tl
    \int_gset:Nn \g_ropas_logo_lines_int {\l_tmpa_tl}
    \int_set_eq:NN \l_ropas_logo_line_count_int
      \g_ropas_logo_lines_int
    \int_while_do:nn {\l_ropas_logo_cursor_int > 0}
      {
        \prop_get:NxN \l_ropas_logo_dp_previous_prop
          {\int_use:N \l_ropas_logo_cursor_int} \l_tmpa_tl
        \prop_gput:Nxx \g_ropas_data_prop
          {logo/line/\int_use:N \l_ropas_logo_line_count_int/end}
          {\int_use:N \l_ropas_logo_cursor_int}
        \prop_gput:Nxx \g_ropas_data_prop
          {logo/line/\int_use:N \l_ropas_logo_line_count_int/start}
          {\int_eval:n {\l_tmpa_tl+1}}
        \int_set:Nn \l_ropas_logo_cursor_int {\l_tmpa_tl}
        \int_decr:N \l_ropas_logo_line_count_int
      }
  }

\cs_new_protected:Npn \ropas_build_logos:
  {
    \seq_if_empty:NTF \g_ropas_logos_seq
      { \vbox_gset:Nn \g_ropas_logo_box { } \int_gzero:N \g_ropas_logo_lines_int }
      {
        \ropas_measure_logos:
        \ropas_logo_choose_optimal_partition:
        \vbox_gset:Nn \g_ropas_logo_box
          {
            \offinterlineskip
            \int_step_inline:nn { \g_ropas_logo_lines_int }
              {
                \prop_get:NxN \g_ropas_data_prop { logo/line/##1/start }
                  \l_tmpa_tl
                \prop_get:NxN \g_ropas_data_prop { logo/line/##1/end }
                  \l_tmpb_tl
                \int_set:Nn \l_tmpa_int { \l_tmpb_tl - \l_tmpa_tl + 1 }
                \dim_set:Nn \l_tmpa_dim
                  { \g_ropas_body_width_dim / \l_tmpa_int }
                \hbox to \g_ropas_body_width_dim
                  {
                    \int_step_inline:nnn { \l_tmpa_tl } { \l_tmpb_tl }
                      {
                        \hbox to \l_tmpa_dim
                          { \hss
                            \box_use:c { g_ropas_logo_####1_box }
                            \hss }
                      }
                  }
                \int_compare:nNnF {##1} = { \g_ropas_logo_lines_int }
                  { \vskip \g_ropas_body_top_dim }
              }
          }
      }
  }

\cs_new_protected:Npn \ropas_document_begin:
  {
    \ropas_validate_document_settings:
    \ropas_reset_default_size_base:
    \pagestyle{empty}
    \thispagestyle{empty}
    \topskip=0pt
    \offinterlineskip
    \tl_set:Nn \l_ropas_context_tl { document }
    \dim_gzero:N \g_ropas_document_title_reserve_dim
    \ropas_theorem_style_enter:n {\g_ropas_text_size_dim}
    \tl_gset:Nn \g_ropas_current_footnote_owner_tl {document}
    \seq_gclear:c {g_ropas_child_document_notes_seq}
    \seq_gclear:N \g_ropas_float_top_seq
    \seq_gclear:N \g_ropas_float_bottom_seq
    \ropas_page_begin:
    \vbox_gset:Nw \g_ropas_document_body_box
      \hsize=\g_ropas_body_width_dim
      \linewidth=\hsize
      \columnwidth=\hsize
      \textwidth=\hsize
      \parindent=\g_ropas_paragraph_indent_dim
      \parskip=\dim_eval:n
        { \g_ropas_paragraph_leading_dim - \g_ropas_text_leading_dim }
      \leftskip=0pt
      \rightskip=0pt
      \parfillskip=0pt plus 1fil
      \sffamily
      \ropas_load_style_from_globals:
      \ropas_install_acmsmall_lists:
      \captionsetup{font=ropas-cell,singlelinecheck=true}
      \fontsize{\g_ropas_text_size_dim}
        { \dim_eval:n
            { \g_ropas_text_size_dim + \g_ropas_text_leading_dim } }
      \selectfont
      \tabcolsep=.5\g_ropas_text_size_dim
      \color{\g_ropas_text_colour_tl}
      \dim_set_eq:NN \l_ropas_cell_inner_width_dim \g_ropas_body_width_dim
      \ropas_install_block_floats:
      \bool_set_false:N \l_ropas_document_title_seen_bool
      \bool_set_false:N \l_ropas_document_content_seen_bool
      \bool_gset_false:N \g_ropas_document_content_seen_bool
      \everypar
        { \bool_set_true:N \l_ropas_document_content_seen_bool
          \bool_gset_true:N \g_ropas_document_content_seen_bool }
      \cs_set_protected:Npn \blocktitle ##1
        {
          \bool_if:NT \l_ropas_document_title_seen_bool
            { \ropas_class_error:nn
                { More~than~one~blocktitle~in~document }
                { Use~at~most~one~blocktitle. } }
          \bool_if:NT \l_ropas_document_content_seen_bool
            { \ropas_class_error:nn
                { blocktitle~must~be~first~in~document }
                { Move~blocktitle~before~the~body. } }
          \bool_set_true:N \l_ropas_document_title_seen_bool
          \vbox_gset:Nn \g_ropas_document_title_box
            {
              \hsize=\g_ropas_body_width_dim
              \parindent=0pt\parskip=0pt
              \everypar{}
              \noindent
              { \sffamily\bfseries
                \fontsize{\g_ropas_cell_title_size_dim}
                  { \dim_eval:n
                      { \g_ropas_cell_title_size_dim
                        + \g_ropas_text_leading_dim } }
                \selectfont\color{\g_ropas_cell_title_colour_tl}##1\par }
            }
          \dim_gset:Nn \g_ropas_document_title_reserve_dim
            { \box_ht:N \g_ropas_document_title_box
              + \box_dp:N \g_ropas_document_title_box
              + \g_ropas_paragraph_leading_dim }
          \box_use:N \g_ropas_document_title_box
          \vskip \g_ropas_paragraph_leading_dim
        }
      \cs_set_protected:Npn \sectiontitle ##1
        { \ropas_heading:nnn { \g_ropas_section_title_size_dim }
            { \g_ropas_section_title_colour_tl } {##1} }
      \cs_set_protected:Npn \columnbreak
        { \par\penalty -10000\relax }
  }

% Graphics inclusion is deferred until the first poster environment.  Some
% graphics drivers cannot safely open an image while LaTeX is still executing
% its begin-document hooks.
\cs_new_protected:Npn \ropas_page_begin:
  {
    \bool_if:NF \g_ropas_page_started_bool
      {
        \bool_gset_true:N \g_ropas_page_started_bool
        \group_begin:
          \everypar { }
    \dim_gset:Nn \g_ropas_body_width_dim
      { \g_ropas_paper_width_dim - 2\g_ropas_body_side_dim }
    \ropas_build_header:
    \ropas_build_logos:
    \box_use:N \g_ropas_header_box
    \vskip \g_ropas_body_top_dim
    \seq_if_empty:NF \g_ropas_logos_seq
      { \hbox to \g_ropas_paper_width_dim
          { \hskip\g_ropas_body_side_dim \box_use:N\g_ropas_logo_box
            \hskip\g_ropas_body_side_dim }
        \vskip \g_ropas_body_top_dim }
    \dim_gset:Nn \g_ropas_body_height_dim
      {
        \g_ropas_paper_height_dim
        - \box_ht:N \g_ropas_header_box - \box_dp:N \g_ropas_header_box
        - \g_ropas_body_top_dim - \g_ropas_body_bottom_dim
        - \box_ht:N \g_ropas_logo_box - \box_dp:N \g_ropas_logo_box
      }
    \seq_if_empty:NF \g_ropas_logos_seq
      { \dim_gsub:Nn \g_ropas_body_height_dim { \g_ropas_body_top_dim } }
    \dim_compare:nNnF { \g_ropas_body_height_dim } > {0pt}
      { \ropas_class_error:nn { Header,~logos,~and~margins~consume~the~page }
          { Reduce~their~sizes~so~that~the~poster~body~has~positive~height. }
        \dim_gset:Nn \g_ropas_body_height_dim {1pt} }
    \hbox_gset:Nn \g_ropas_background_box
      {
        \setlength\unitlength{1pt}
        \begin{picture}(0,0)
          \put(0pt,0pt)
            { \tl_use:N \g_ropas_header_background_tl
                { \g_ropas_paper_width_dim }
                { \g_ropas_header_height_dim } }
          \put(0pt,-\g_ropas_header_height_dim)
            { \tl_use:N \g_ropas_body_background_tl
                { \g_ropas_paper_width_dim }
                { \dim_eval:n
                    { \g_ropas_paper_height_dim
                      - \g_ropas_header_height_dim } } }
        \end{picture}
      }
        \group_end:
      }
  }

\cs_new_protected:Npn \ropas_output_grid:n #1
  {
    \ropas_grid_measure_min:nn {#1} { \g_ropas_body_width_dim }
    \ropas_grid_render:nnn {#1}
      { \g_ropas_body_width_dim } { \g_ropas_body_height_dim }
    \hbox to \g_ropas_paper_width_dim
      { \hskip \g_ropas_body_side_dim
        \box_use:c { g_ropas_grid_#1_render_box }
        \hskip \g_ropas_body_side_dim }
    \bool_gset_true:N \g_ropas_grid_output_bool
  }

\cs_new_protected:Npn \ropas_document_end:
  {
    \par
    \bool_if:NT \g_ropas_grid_output_bool
      { \bool_if:NT \g_ropas_document_content_seen_bool
          { \ropas_class_error:nn
              { document~grid~has~ordinary~body~content }
              { Keep~only~an~optional~blocktitle~and~one~postergrid. } } }
    \vbox_gset_end:
    \ropas_build_float_queue_box:nnn
      {document}{top}{\g_ropas_body_width_dim}
    \ropas_build_float_queue_box:nnn
      {document}{bottom}{\g_ropas_body_width_dim}
    \ropas_theorem_style_leave:
    \ropas_load_style_from_globals:
    \ropas_build_footnotes:nn {document}{\g_ropas_body_width_dim}
    \bool_if:NTF \g_ropas_grid_output_bool
      { \box_use:N \g_ropas_document_body_box
        \box_use:c {g_ropas_child_document_footnote_box} }
      {
        \dim_compare:nNnT
          { \box_ht:N \g_ropas_document_body_box
            + \box_dp:N \g_ropas_document_body_box }
          > { \g_ropas_body_height_dim }
          { \ropas_class_info:n { Document~body~overflows~its~content~area } }
        \hbox to \g_ropas_paper_width_dim
          { \hskip\g_ropas_body_side_dim
            \vbox to \g_ropas_body_height_dim
              { \box_use:c {g_ropas_child_document_top_float_box}
                \box_use:N \g_ropas_document_body_box
                \vfil
                \box_use:c {g_ropas_child_document_bottom_float_box}
                \box_use:c {g_ropas_child_document_footnote_box} }
            \hskip\g_ropas_body_side_dim }
      }
    \vskip \g_ropas_body_bottom_dim
  }

\AddToHook { begindocument/end } { \ropas_document_begin: }
\AddToHook { enddocument } { \ropas_document_end: }

% --------------------------------------------------------------------------
% Public grid environments
% --------------------------------------------------------------------------

\tl_new:N \l_ropas_environment_grid_tl
\bool_new:N \l_ropas_environment_valid_bool
\bool_new:N \l_ropas_environment_nested_bool
\tl_new:N \l_ropas_container_child_tl
\tl_new:N \l_ropas_capture_row_tl
\tl_new:N \l_ropas_capture_col_tl
\tl_new:N \l_ropas_capture_options_tl
\tl_new:N \l_ropas_capture_body_tl
\tl_new:N \l_ropas_capture_suffix_tl
\tl_new:N \g_ropas_capture_raw_tl
\str_new:N \g_ropas_block_begin_marker_str
\str_new:N \g_ropas_block_end_marker_str
\str_new:N \g_ropas_star_block_begin_marker_str
\str_new:N \g_ropas_star_block_end_marker_str
\str_new:N \g_ropas_grid_begin_marker_str
\int_new:N \l_ropas_block_capture_nesting_int
\bool_new:N \l_ropas_capture_star_bool
\bool_new:N \l_ropas_capture_first_content_bool
\bool_new:N \l_ropas_capture_title_first_bool
\bool_new:N \l_ropas_immediate_empty_block_bool
\str_new:N \l_ropas_capture_line_str
\str_new:N \l_ropas_capture_prefix_str
\str_new:N \l_ropas_capture_next_str

\str_gset:Nx \g_ropas_block_begin_marker_str
  {
    \c_backslash_str begin
    \c_left_brace_str posterblock \c_right_brace_str
  }
\str_gset:Nx \g_ropas_block_end_marker_str
  {
    \c_backslash_str end
    \c_left_brace_str posterblock \c_right_brace_str
  }
\str_gset:Nx \g_ropas_star_block_begin_marker_str
  {
    \c_backslash_str begin
    \c_left_brace_str posterblock* \c_right_brace_str
  }
\str_gset:Nx \g_ropas_star_block_end_marker_str
  {
    \c_backslash_str end
    \c_left_brace_str posterblock* \c_right_brace_str
  }
\str_gset:Nx \g_ropas_grid_begin_marker_str
  {
    \c_backslash_str begin
    \c_left_brace_str postergrid \c_right_brace_str
  }

\cs_generate_variant:Nn \seq_set_split_keep_spaces:Nnn { NV }

\cs_new_protected:Npn \ropas_grid_registration_begin:n #1
  {
    \vbox_gset:cw { g_ropas_grid_#1_registration_box }
      \hsize=1pt
      \linewidth=\hsize
      \parindent=0pt
      \everypar { }
      \hfuzz=\maxdimen
      \hbadness=10000
      \vfuzz=\maxdimen
      \vbadness=10000
  }

\cs_new_protected:Npn \ropas_grid_registration_end:n #1
  {
    \vbox_gset_end:
    \dim_compare:nNnT
      {
        \box_ht:c { g_ropas_grid_#1_registration_box }
        + \box_dp:c { g_ropas_grid_#1_registration_box }
        + \box_wd:c { g_ropas_grid_#1_registration_box }
      }
      > { 0pt }
      {
        \ropas_class_error:nn
          { A~postergrid~contains~material~outside~posterblock }
          { Put~every~direct~child~of~postergrid~inside~posterblock. }
      }
  }

\cs_new_protected:Npn \ropas_require_document_context:n #1
  {
    \str_if_eq:VnF \l_ropas_context_tl { document }
      { \ropas_class_error:nn { #1~is~not~allowed~in~this~context }
          { Use~it~directly~inside~document~or~inside~a~grid,~as~documented. } }
  }

\cs_new_protected:Npn \ropas_top_grid_begin:n #1
  {
    \ropas_require_document_context:n { postergrid }
    \bool_if:NT \g_ropas_document_content_seen_bool
      { \ropas_class_error:nn
          { document~contains~body~content~before~postergrid }
          { Keep~only~an~optional~blocktitle~before~postergrid. } }
    \ropas_page_begin:
    \bool_set_false:N \l_ropas_environment_valid_bool
    \int_compare:nNnTF { \g_ropas_top_grid_count_int } = {0}
      {
        \dim_gsub:Nn \g_ropas_body_height_dim
          { \g_ropas_document_title_reserve_dim }
        \int_gincr:N \g_ropas_top_grid_count_int
        \bool_set_true:N \l_ropas_environment_valid_bool
        \ropas_grid_initialize:nnN {0}{#1}\l_ropas_environment_grid_tl
        \bool_set_true:N \l_ropas_register_bool
        \int_set:Nn \l_ropas_current_grid_int
          { \l_ropas_environment_grid_tl }
        \exp_args:NV \ropas_grid_registration_begin:n
          \l_ropas_environment_grid_tl
      }
      { \ropas_class_error:nn { More~than~one~postergrid~was~used }
          { A~document~may~contain~at~most~one~top-level~postergrid. } }
  }

\cs_new_protected:Npn \ropas_top_grid_end:
  {
    \bool_if:NT \l_ropas_environment_valid_bool
      {
        \exp_args:NV \ropas_grid_registration_end:n
          \l_ropas_environment_grid_tl
        \exp_args:NV \ropas_output_grid:n \l_ropas_environment_grid_tl
      }
  }

\cs_new_protected:Npn \ropas_nested_grid_begin:n #1
  {
    \bool_set_false:N \l_ropas_environment_valid_bool
    \bool_set_true:N \l_ropas_environment_nested_bool
    \prop_get:NxN \g_ropas_data_prop
      { child/\l_ropas_container_child_tl/has-grid } \l_tmpa_tl
    \str_if_eq:VnTF \l_tmpa_tl { true }
      {
        \ropas_class_error:nn
          { A~posterblock~contains~more~than~one~direct~postergrid }
          { Keep~exactly~one~direct~postergrid~in~a~grid~block. }
      }
      {
        \prop_get:NxN \g_ropas_data_prop
          { child/\l_ropas_container_child_tl/parent } \l_tmpa_tl
        \exp_args:NV \ropas_grid_initialize:nnN \l_tmpa_tl {#1}
          \l_ropas_environment_grid_tl
        \prop_gput:NxV \g_ropas_data_prop
          { child/\l_ropas_container_child_tl/grid }
          \l_ropas_environment_grid_tl
        \prop_gput:Nxn \g_ropas_data_prop
          { child/\l_ropas_container_child_tl/has-grid } { true }
        \bool_set_true:N \l_ropas_environment_valid_bool
        \bool_set_true:N \l_ropas_register_bool
        \int_set:Nn \l_ropas_current_grid_int
          { \l_ropas_environment_grid_tl }
        \exp_args:NV \ropas_grid_registration_begin:n
          \l_ropas_environment_grid_tl
      }
  }

\cs_new_protected:Npn \ropas_nested_grid_end:
  {
    \bool_if:NT \l_ropas_environment_valid_bool
      { \exp_args:NV \ropas_grid_registration_end:n
          \l_ropas_environment_grid_tl }
  }

\cs_new_protected:Npn \ropas_grid_begin:n #1
  {
    \str_if_eq:VnTF \l_ropas_context_tl { block-registration }
      { \ropas_nested_grid_begin:n {#1} }
      {
        \bool_set_false:N \l_ropas_environment_nested_bool
        \ropas_top_grid_begin:n {#1}
      }
  }

\cs_new_protected:Npn \ropas_grid_end:
  {
    \bool_if:NTF \l_ropas_environment_nested_bool
      { \ropas_nested_grid_end: }
      { \ropas_top_grid_end: }
  }

\cs_new_protected:Npn \ropas_cell_capture_catcodes:
  {
    \int_step_inline:nnnn {0}{1}{255}
      { \char_set_catcode_other:n {##1} }
    \char_set_catcode_active:N \^^M
  }

\cs_new_protected:Npn \ropas_cell_capture_note_first:n #1
  {
    \bool_if:NF \l_ropas_capture_first_content_bool
      {
        \str_set:Nx \l_ropas_capture_line_str
          {#1}
        % Cell bodies are captured with space characters made "other" so
        % verbatim input survives.  Regex whitespace matching handles those
        % characters when locating the first meaningful source token.
        \regex_replace_once:nnN { \A \s+ } { }
          \l_ropas_capture_line_str
        \regex_replace_once:nnN { \s+ \Z } { }
          \l_ropas_capture_line_str
        \str_if_empty:NF \l_ropas_capture_line_str
          {
            \str_if_eq:eeF
              { \str_item:Nn \l_ropas_capture_line_str {1} }
              { \c_percent_str }
              {
                \bool_gset_true:N \l_ropas_capture_first_content_bool
                \str_set:Nx \l_ropas_capture_prefix_str
                  { \str_range:Nnn \l_ropas_capture_line_str {1}{11} }
                \str_set:Nx \l_ropas_capture_next_str
                  { \str_item:Nn \l_ropas_capture_line_str {12} }
                \str_if_eq:eeT
                  { \l_ropas_capture_prefix_str }
                  { \c_backslash_str blocktitle }
                  {
                    \str_if_empty:NTF \l_ropas_capture_next_str
                      { \bool_gset_true:N \l_ropas_capture_title_first_bool }
                      {
                        \exp_args:Nee \str_if_in:nnTF
                          {abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ@}
                          { \l_ropas_capture_next_str }
                          { }
                          { \bool_gset_true:N
                              \l_ropas_capture_title_first_bool }
                      }
                  }
              }
          }
      }
  }

\cs_new_protected:Npn \ropas_cell_capture_append:n #1
  {
    \tl_gput_right:Nn \g_ropas_capture_raw_tl {#1}
    % A character-code-10 token becomes a physical line boundary in the
    % e-TeX pseudo-input stream used by \scantokens.
    \tl_gput_right:Nx \g_ropas_capture_raw_tl
      { \char_generate:nn {10}{12} }
  }

\cs_new_protected:Npn \ropas_cell_capture_process:n #1
  {
    \seq_set_split_keep_spaces:NVn \l_tmpa_seq
      \g_ropas_block_begin_marker_str {#1}
    \int_set:Nn \l_tmpa_int { \seq_count:N \l_tmpa_seq - 1 }
    \seq_set_split_keep_spaces:NVn \l_tmpa_seq
      \g_ropas_star_block_begin_marker_str {#1}
    \int_add:Nn \l_tmpa_int { \seq_count:N \l_tmpa_seq - 1 }
    \seq_set_split_keep_spaces:NVn \l_tmpa_seq
      \g_ropas_block_end_marker_str {#1}
    \int_set:Nn \l_tmpb_int { \seq_count:N \l_tmpa_seq - 1 }
    \seq_set_split_keep_spaces:NVn \l_tmpa_seq
      \g_ropas_star_block_end_marker_str {#1}
    \int_add:Nn \l_tmpb_int { \seq_count:N \l_tmpa_seq - 1 }
    \int_compare:nNnTF
      { \l_tmpb_int } >
      { \l_ropas_block_capture_nesting_int + \l_tmpa_int }
      {
        \bool_if:NTF \l_ropas_capture_star_bool
          { \seq_set_split_keep_spaces:NVn \l_tmpa_seq
              \g_ropas_star_block_end_marker_str {#1} }
          { \seq_set_split_keep_spaces:NVn \l_tmpa_seq
              \g_ropas_block_end_marker_str {#1} }
        \seq_pop_left:NN \l_tmpa_seq \l_tmpa_tl
        \tl_if_empty:VF \l_tmpa_tl
          {
            \exp_args:NV \ropas_cell_capture_note_first:n \l_tmpa_tl
            \exp_args:NV \ropas_cell_capture_append:n \l_tmpa_tl
          }
        \tl_clear:N \l_ropas_capture_suffix_tl
        \seq_if_empty:NF \l_tmpa_seq
          { \seq_pop_left:NN \l_tmpa_seq \l_ropas_capture_suffix_tl }
        \exp_args:NV \ropas_cell_capture_finish:n
          \l_ropas_capture_suffix_tl
      }
      {
        \ropas_cell_capture_note_first:n {#1}
        \ropas_cell_capture_append:n {#1}
        \int_add:Nn \l_ropas_block_capture_nesting_int
          { \l_tmpa_int - \l_tmpb_int }
        \ropas_cell_capture_line:w
      }
  }

\group_begin:%
\char_set_catcode_active:N \^^M%
\cs_gset_protected:Npn \ropas_cell_capture_line:w #1^^M%
  { \ropas_cell_capture_process:n {#1} }%
\group_end:

\cs_new_protected:Npn \ropas_cell_capture_begin:nnnn #1#2#3#4
  {
    \str_if_eq:nnTF {#1}{true}
      { \bool_set_true:N \l_ropas_capture_star_bool }
      { \bool_set_false:N \l_ropas_capture_star_bool }
    \tl_set:Nn \l_ropas_capture_row_tl {#2}
    \tl_set:Nn \l_ropas_capture_col_tl {#3}
    \tl_set:Nn \l_ropas_capture_options_tl {#4}
    \int_zero:N \l_ropas_block_capture_nesting_int
    \bool_gset_false:N \l_ropas_capture_first_content_bool
    \bool_gset_false:N \l_ropas_capture_title_first_bool
    \tl_gclear:N \g_ropas_capture_raw_tl
    \group_begin:
      \ropas_cell_capture_catcodes:
      \ropas_cell_capture_line:w
  }

\cs_generate_variant:Nn \ropas_register_block:nnnn { VVVV }
\cs_generate_variant:Nn \ropas_register_grid_block:nnnnn { VVVVn }
\cs_generate_variant:Nn \str_if_in:nnTF { VV }

\cs_new_protected:Npn \ropas_cell_replay:n #1
  {
    \group_begin:
      \tex_endlinechar:D=13
      \tex_scantokens:D {#1}
    \group_end:
  }

\cs_new_protected:Npn \ropas_cell_capture_end:
  {
    \tl_set:Nx \l_ropas_capture_body_tl
      {
        \exp_not:N \ropas_cell_replay:n
          { \exp_not:V \g_ropas_capture_raw_tl }
      }
    \bool_if:NTF \l_ropas_register_bool
      {
        \str_if_in:VVTF \g_ropas_capture_raw_tl
          \g_ropas_grid_begin_marker_str
          {
            \bool_if:NTF \l_ropas_capture_star_bool
              {
                \ropas_register_grid_block:VVVVn
                  \l_ropas_capture_row_tl
                  \l_ropas_capture_col_tl
                  \l_ropas_capture_options_tl
                  \l_ropas_capture_body_tl {true}
              }
              {
                \ropas_register_grid_block:VVVVn
                  \l_ropas_capture_row_tl
                  \l_ropas_capture_col_tl
                  \l_ropas_capture_options_tl
                  \l_ropas_capture_body_tl {false}
              }
          }
          {
            \bool_if:NT \l_ropas_capture_star_bool
              {
                \bool_if:NT \l_ropas_capture_first_content_bool
                  { \ropas_class_error:nn
                      { posterblock*~contains~content~outside~postergrid }
                      { Only~a~postergrid~or~whitespace~is~allowed. } }
              }
            \ropas_register_block:VVVV
              \l_ropas_capture_row_tl
              \l_ropas_capture_col_tl
              \l_ropas_capture_options_tl
              \l_ropas_capture_body_tl
            \bool_if:NT \l_ropas_capture_star_bool
              { \prop_gput:Nxn \g_ropas_data_prop
                  {child/\l_ropas_child_tl/type} {empty-subgrid} }
          }
      }
      {
        \ropas_class_error:nn { posterblock~is~not~allowed~here }
          { Use~posterblock~directly~inside~postergrid. }
      }
  }

\cs_new_protected:Npn \ropas_cell_capture_finish:n #1
  {
    \group_end:
    \bool_if:NTF \l_ropas_capture_star_bool
      { \end{posterblock*} }
      { \end{posterblock} }
    \tl_if_blank:nF {#1}
      {
        \tl_set_rescan:Nnn \l_tmpa_tl { } {#1}
        \tl_use:N \l_tmpa_tl
      }
  }

\NewDocumentEnvironment { postergrid } { m m !O{} }
  { \ropas_grid_begin:n { row-count=#1,col-count=#2,#3 } }
  { \ropas_grid_end: }

\NewDocumentEnvironment { posterblock } { m m !O{} }
  {
    \bool_set_false:N \l_ropas_immediate_empty_block_bool
    \peek_meaning:NTF \end
      {
        \bool_set_true:N \l_ropas_immediate_empty_block_bool
        \ropas_register_block:nnnn {#1}{#2}{#3}{}
      }
      {\ropas_cell_capture_begin:nnnn {false}{#1}{#2}{#3}}
  }
  { \bool_if:NF \l_ropas_immediate_empty_block_bool
      {\ropas_cell_capture_end:} }

\NewDocumentEnvironment { posterblock* } { m m !O{} }
  {
    \bool_set_false:N \l_ropas_immediate_empty_block_bool
    \peek_meaning:NTF \end
      {
        \bool_set_true:N \l_ropas_immediate_empty_block_bool
        \tl_if_blank:nF {#3}
          {\ropas_class_error:nn
            { posterblock*~does~not~accept~options }
            { Put~options~on~its~nested~postergrid. }}
        \ropas_register_block:nnnn {#1}{#2}{}{}
        \prop_gput:Nxn \g_ropas_data_prop
          {child/\l_ropas_child_tl/type} {empty-subgrid}
      }
      {\ropas_cell_capture_begin:nnnn {true}{#1}{#2}{#3}}
  }
  { \bool_if:NF \l_ropas_immediate_empty_block_bool
      {\ropas_cell_capture_end:} }

\ExplSyntaxOff
