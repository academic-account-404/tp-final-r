library(shiny)
library(bslib)
library(tidyverse)
library(ggplot2)
library(plotly)
library(janitor)
library(stringi)
library(scales)

# Define UI
ui <- page_navbar(
  theme = bs_theme(
    version = 5,
    preset = "flatly",
    primary = "#074F57",
    secondary = "#077187"
  ),
  
  # PAGE 1: HOME
  nav_panel(
    title = "Accueil",
    
    tags$head(
      tags$style(HTML("
      @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,700;1,400&family=Source+Sans+3:wght@300;400;600&display=swap');

      .home-wrapper {
        min-height: 90vh;
        background: linear-gradient(160deg, #f8f9fa 60%, #e8f4f6 100%);
        padding: 0;
      }

      .home-hero {
        padding: 80px 60px 50px 60px;
        border-bottom: 1px solid #dee2e6;
        position: relative;
        overflow: hidden;
      }

      .home-hero::before {
        content: '';
        position: absolute;
        top: -80px; right: -80px;
        width: 400px; height: 400px;
        border-radius: 50%;
        background: radial-gradient(circle, rgba(7,113,135,0.08) 0%, transparent 70%);
        pointer-events: none;
      }

      .home-eyebrow {
        font-size: 0.78rem;
        font-weight: 600;
        letter-spacing: 0.18em;
        text-transform: uppercase;
        color: #077187;
        margin-bottom: 20px;
      }

      .home-title {
        font-size: clamp(1.9rem, 3.5vw, 2.8rem);
        font-weight: 700;
        color: #074F57;
        line-height: 1.2;
        margin-bottom: 16px;
        max-width: 820px;
      }

      .home-title em {
        font-style: italic;
        color: #077187;
      }

      .home-subtitle {
        font-size: 1rem;
        font-weight: 300;
        color: #6c757d;
        letter-spacing: 0.04em;
        margin-bottom: 0;
      }

      .home-body {
        padding: 50px 60px 60px 60px;
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 32px;
        max-width: 1100px;
      }

      .home-context-card {
        background: white;
        border-left: 3px solid #077187;
        border-radius: 4px;
        padding: 32px 36px;
        box-shadow: 0 2px 12px rgba(7,79,87,0.07);
        grid-column: 1 / -1;
      }

      .home-context-card h5 {
        font-size: 0.72rem;
        font-weight: 600;
        letter-spacing: 0.15em;
        text-transform: uppercase;
        color: #077187;
        margin-bottom: 18px;
      }

      .home-context-card p {
        font-size: 0.95rem;
        font-weight: 400;
        color: #343a40;
        line-height: 1.75;
        margin-bottom: 14px;
      }

      .home-context-card p:last-child { margin-bottom: 0; }

      .home-stat-card {
        background: white;
        border-radius: 4px;
        padding: 28px 32px;
        box-shadow: 0 2px 12px rgba(7,79,87,0.07);
        display: flex;
        flex-direction: column;
        gap: 6px;
      }

      .home-stat-number {
        font-size: 2.4rem;
        font-weight: 700;
        color: #074F57;
        line-height: 1;
      }

      .home-stat-label {
        font-size: 0.85rem;
        color: #6c757d;
        font-weight: 400;
      }

      .home-stat-card .home-eyebrow {
        font-size: 0.68rem;
        margin-bottom: 10px;
      }
    "))
    ),
    
    div(class = "home-wrapper",
        
        # Hero
        div(class = "home-hero",
            div(class = "home-eyebrow", "Étude statistique · Données SNCF 2018–2024"),
            h1(class = "home-title",
               "Régularité et fréquentation des trains Intercités en France :",
               tags$br(),
               tags$em("Une corrélation existe-t-elle ?")
            ),
            p(class = "home-subtitle", "Analyse statistique des données ouvertes SNCF")
        ),
        
        # Body
        div(class = "home-body",
            
            # Context card
            div(class = "home-context-card",
                tags$h5("Contexte & Objectifs"),
                p("La ponctualité des trains est un enjeu central de la satisfaction des voyageurs et de la crédibilité du service public ferroviaire. En France, la SNCF publie régulièrement des données ouvertes sur la régularité de ses liaisons Intercités ainsi que sur la fréquentation de ses gares, offrant une opportunité d'analyse statistique approfondie."),
                p("L'objectif principal de cette étude est de déterminer s'il existe une corrélation entre la fréquentation d'une gare de départ et le taux de régularité des liaisons qui en sont issues. Deux hypothèses intuitives mais opposées peuvent en effet être formulées a priori : d'un côté, les gares les plus fréquentées pourraient bénéficier d'investissements prioritaires favorisant une meilleure ponctualité ; de l'autre, un trafic plus dense pourrait engendrer une saturation du réseau et dégrader la régularité."),
                p("Afin de répondre à cette question, l'analyse s'articule en plusieurs étapes. Dans un premier temps, nous décrivons la distribution et l'évolution temporelle de la fréquentation des gares françaises. Dans un second temps, nous étudions la distribution des liaisons, ainsi que les plus et les moins performantes du réseau Intercité. Enfin, nous mobilisons un test de corrélation pour évaluer statistiquement l'existence d'un lien entre ces deux dimensions.")
            ),
            
            # Stat cards
            div(class = "home-stat-card",
                div(class = "home-eyebrow", "Période couverte"),
                div(class = "home-stat-number", "2018–2024"),
                div(class = "home-stat-label", "7 années de données mensuelles")
            ),
            
            div(class = "home-stat-card",
                div(class = "home-eyebrow", "Réseau analysé"),
                div(class = "home-stat-number", "Intercités"),
                div(class = "home-stat-label", "Liaisons nationales, régionales et locales")
            )
        )
    )
  ),
  
  # PAGE 2: GARES
  nav_panel(
    title = "Gares",
    layout_sidebar(
      sidebar = sidebar(
        tags$h4(class = "fw-bold", "Filtre d'analyse"),
        width = 250,
        
        # Slider 1 → only for Evolution tab
        conditionalPanel(
          condition = "input.gares_tabs == 'Évolution temporelle'",
          sliderInput(
            inputId = "date_range",
            label = "Période temporelle",
            min = 2018,
            max = 2024,
            value = c(2018, 2024),
            step = 1,
            sep = ""
          )
        ),
        
        # Slider 2 → for 2 other tabs
        conditionalPanel(
          condition = "input.gares_tabs == 'Densité' ||
                  input.gares_tabs == 'Plus fréquentées'",
          sliderInput(
            inputId = "mean_voyageurs_filter",
            label = "Nombre de voyageurs",
            min = 0,
            max = 250,
            value = 250,
            step = 1,
            post = "M"
          )
        )
      ),
      navset_card_tab(
        id = "gares_tabs",
        nav_panel(
          title = "Densité",
          plotOutput("gares_densite")
          
        ),
        nav_panel(
          title = "Évolution temporelle",
          plotOutput("gares_evolution")
        ),
        nav_panel(
          title = "Plus fréquentées",
          plotOutput("gares_more_frequented")
        )
      )
    )
  ),
  
  # PAGE 3: LIAISONS
  nav_panel(
    title = "Liaisons",
    layout_sidebar(
      sidebar = sidebar(
        tags$h4(class = "fw-bold", "Filtre d'analyse"),
        width = 250,
        
        conditionalPanel(
          condition = "input.liaisons_tab == 'liaisons_evolution'",
          sliderInput(
            inputId = "date_range_liaisons",
            label = "Période temporelle",
            min = as.Date("2018-01-01"),
            max = as.Date("2024-12-01"),
            value = c(as.Date("2018-01-01"), as.Date("2024-12-01")),
            step = 1,
            timeFormat = "%Y-%m"
          )
        ),
        
        # Slider 2 → for 2 other tabs
        conditionalPanel(
          condition = "
            input.liaisons_tab == 'liaisons_densite' ||
            input.liaisons_tab == 'liaisons_more_regular' ||
            input.liaisons_tab == 'liaisons_less_regular'
          ",
          sliderInput(
            inputId = "mean_voyageurs_filter_liaisons",
            label = "Nombre de voyageurs",
            min = 0,
            max = 250,
            value = c(0,250),
            step = 1,
            post    = "M"
          )
        )
      ),
      navset_card_tab(
        id = "liaisons_tab",
        nav_panel(
          title = "Densité",
          value = "liaisons_densite",
          plotOutput("liaisons_densite")
          
        ),
        nav_panel(
          title = "Évolution temporelle",
          value = "liaisons_evolution",
          plotOutput("liaisons_evolution")
        ),
        nav_panel(
          title = "Plus régulières",
          value = "liaisons_more_regular",
          plotOutput("liaisons_more_regular")
        ),
        nav_panel(
          title = "Moins régulières",
          value = "liaisons_less_regular",
          plotOutput("liaisons_less_regular")
        )
      )
    )
  ),
  
  # PAGE 4: CORRELATION
  nav_panel(
    title = "Corrélation",
    layout_sidebar(
      sidebar = sidebar(
        tags$h4(class = "fw-bold", "Filtre d'analyse"),
        width = 250,
        
        conditionalPanel(
          condition = "input.correlation_tabs == 'correlation_evolution'",
          sliderInput(
            inputId = "date_range_correlation",
            label = "Période temporelle",
            min = as.Date("2018-01-01"),
            max = as.Date("2024-12-01"),
            value = c(as.Date("2018-01-01"), as.Date("2024-12-01")),
            step = 1,
            timeFormat = "%Y-%m"
          )
        ),
        
        # Slider 2 → for 2 other tabs
        conditionalPanel(
          condition = "input.correlation_tabs == 'correlation_linear'",
          sliderInput(
            inputId = "mean_voyageurs_filter_correlation",
            label = "Nombre de voyageurs",
            min = 0,
            max = 250,
            value = c(0,250),
            step = 1,
            post = "M"
          )
        )
      ),
      navset_card_tab(
        id = "correlation_tabs",
        nav_panel(
          title = "Régression linéaire",
          value = "correlation_linear",
          plotOutput("correlation_linear")
          
        ),
        nav_panel(
          title = "Évolution du coefficient de corrélation",
          value = "correlation_evolution",
          plotOutput("correlation_evolution")
        ),
        nav_panel(
          title = "Corrélation de Kendall",
          
          withMathJax(
            tagList(
              
              tags$p(
                "Nous souhaitons vérifier statistiquement s'il existe une corrélation entre le nombre de voyageurs et la régularité des liaisons. ",
                "Pour cela, nous étudions les variables continues ",
                tags$code("voyageurs_avg"), " et ", tags$code("taux_reg"), ". ",
                "Sachant que nous avons des valeurs extrêmes, le test de Pearson promet des résultats peu fiables. ",
                "À la place, nous allons utiliser le test de ",
                tags$b("corrélation de Kendall"), "."
              ),
              
              tags$h4("Hypothèses"),
              
              tags$div(
                HTML("
$$H_0 : \\tau = 0 \\quad \\text{(aucune corrélation)}$$  
$$H_1 : \\tau \\ne 0 \\quad \\text{(il existe une relation monotone entre les deux variables)}$$
")
              ),
              
              tags$h4("Résultats du test"),
              
              uiOutput("correlation_kendall"),
              
              tags$h4("Conclusion"),
              
              tags$p(
                "La corrélation est quasi nulle (𝜏= -0.01), indiquant qu’il n’existe pratiquement pas de relation monotone entre les deux variables. Par ailleurs, une p-value de 0.89, bien au-dessus du seuil conventionnel de 0.05, signifie qu’on ne peut pas rejeter 𝐻0. 
                Les données sont ainsi compatibles avec une", tags$b("absence totale de corrélation") ,"entre le taux de régularité des trains et la fréquentation de leur gare de départ."
              ),
              
            )
          )
        )
      )
    )
  ),
  
  # PAGE 5: DATA & METHOD
  nav_panel(
    title = "Données & Méthodologie",
    
    tags$head(
      tags$style(HTML("
      @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,700;1,400&family=Source+Sans+3:wght@300;400;600&family=JetBrains+Mono:wght@400;500&display=swap');

      .dm-wrapper {
        background: linear-gradient(160deg, #f8f9fa 60%, #e8f4f6 100%);
        min-height: 90vh;
        padding: 0;
      }

      /* ── Hero ── */
      .dm-hero {
        padding: 60px 60px 40px 60px;
        border-bottom: 1px solid #dee2e6;
        position: relative;
        overflow: hidden;
      }
      .dm-hero::before {
        content: '';
        position: absolute;
        top: -80px; right: -80px;
        width: 400px; height: 400px;
        border-radius: 50%;
        background: radial-gradient(circle, rgba(7,113,135,0.08) 0%, transparent 70%);
        pointer-events: none;
      }
      .dm-eyebrow {
        font-size: 0.75rem;
        font-weight: 600;
        letter-spacing: 0.18em;
        text-transform: uppercase;
        color: #077187;
        margin-bottom: 16px;
      }
      .dm-hero-title {
        font-size: clamp(1.6rem, 2.8vw, 2.2rem);
        font-weight: 700;
        color: #074F57;
        line-height: 1.25;
        margin-bottom: 0;
      }

      /* ── Tab content body ── */
      .dm-body {
        padding: 44px 60px 60px 60px;
        max-width: 960px;
      }

      /* ── Section headings ── */
      .dm-section-title {
        font-size: 1.35rem;
        font-weight: 700;
        color: #074F57;
        margin: 0 0 8px 0;
      }
      .dm-section-rule {
        border: none;
        border-top: 2px solid #077187;
        width: 40px;
        margin: 0 0 22px 0;
      }

      /* ── Dataset cards ── */
      .dm-dataset-card {
        background: white;
        border-radius: 4px;
        border-left: 3px solid #077187;
        padding: 28px 32px;
        box-shadow: 0 2px 12px rgba(7,79,87,0.07);
        margin-bottom: 20px;
      }
      .dm-dataset-card h5 {
        font-size: 0.70rem;
        font-weight: 600;
        letter-spacing: 0.15em;
        text-transform: uppercase;
        color: #077187;
        margin-bottom: 10px;
      }
      .dm-dataset-card h4 {
        font-size: 1.1rem;
        color: #074F57;
        margin-bottom: 14px;
      }
      .dm-dataset-card p {
        font-size: 0.92rem;
        color: #343a40;
        line-height: 1.75;
        margin-bottom: 0;
      }
      .dm-dataset-card a {
        color: #077187;
        text-decoration: underline;
        text-underline-offset: 3px;
      }
      .dm-badge-row {
        display: flex;
        gap: 10px;
        margin-top: 14px;
        flex-wrap: wrap;
      }
      .dm-badge {
        font-size: 0.72rem;
        font-weight: 600;
        letter-spacing: 0.08em;
        padding: 4px 10px;
        border-radius: 2px;
        background: #e8f4f6;
        color: #074F57;
      }

      /* ── Regional org card ── */
      .dm-info-card {
        background: white;
        border-radius: 4px;
        padding: 28px 32px;
        box-shadow: 0 2px 12px rgba(7,79,87,0.07);
        margin-top: 20px;
      }
      .dm-info-card h5 {
        font-size: 0.70rem;
        font-weight: 600;
        letter-spacing: 0.15em;
        text-transform: uppercase;
        color: #077187;
        margin-bottom: 14px;
      }
      .dm-directions-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 8px 24px;
      }
      .dm-direction-item {
        font-size: 0.88rem;
        color: #343a40;
        padding: 6px 0;
        border-bottom: 1px solid #f0f0f0;
        display: flex;
        align-items: center;
        gap: 8px;
      }
      .dm-direction-item::before {
        content: '';
        width: 6px; height: 6px;
        border-radius: 50%;
        background: #077187;
        flex-shrink: 0;
      }

      /* ── Steps ── */
      .dm-step {
        background: white;
        border-radius: 4px;
        padding: 26px 32px;
        box-shadow: 0 2px 12px rgba(7,79,87,0.07);
        margin-bottom: 16px;
        display: grid;
        grid-template-columns: 48px 1fr;
        gap: 0 20px;
        align-items: start;
      }
      .dm-step-number {
        font-size: 2rem;
        font-weight: 700;
        color: #e8f4f6;
        line-height: 1;
        user-select: none;
        padding-top: 2px;
      }
      .dm-step-content h4 {
        font-size: 0.88rem;
        font-weight: 600;
        letter-spacing: 0.06em;
        text-transform: uppercase;
        color: #074F57;
        margin-bottom: 10px;
      }
      .dm-step-content p {
        font-size: 0.92rem;
        color: #343a40;
        line-height: 1.75;
        margin-bottom: 12px;
      }
      .dm-step-content p:last-child { margin-bottom: 0; }

      /* ── Code blocks ── */
      .dm-code {
        background: #1e2a2c;
        border-radius: 3px;
        padding: 16px 20px;
        margin-top: 12px;
        overflow-x: auto;
      }
      .dm-code pre {
        font-size: 0.78rem;
        color: #a8d8df;
        margin: 0;
        white-space: pre;
        line-height: 1.6;
      }
      .dm-code .kw  { color: #77bfd4; }
      .dm-code .fn  { color: #c3e0e5; font-weight: 500; }
      .dm-code .st  { color: #8fbcbb; }
      .dm-code .cm  { color: #5a7a7e; font-style: italic; }
      .dm-code .op  { color: #6eaab5; }

      /* ── Preview table ── */
      .dm-table-wrap {
        background: white;
        border-radius: 4px;
        box-shadow: 0 2px 12px rgba(7,79,87,0.07);
        overflow: hidden;
        margin-top: 4px;
      }
      .dm-table-wrap table {
        width: 100%;
        font-size: 0.85rem;
        border-collapse: collapse;
      }
      .dm-table-wrap thead tr {
        background: #074F57;
        color: white;
      }
      .dm-table-wrap thead th {
        padding: 12px 16px;
        font-weight: 600;
        letter-spacing: 0.04em;
        font-size: 0.78rem;
        text-align: left;
        white-space: nowrap;
      }
      .dm-table-wrap tbody tr:nth-child(even) { background: #f8f9fa; }
      .dm-table-wrap tbody tr:hover { background: #e8f4f6; transition: background 0.15s; }
      .dm-table-wrap tbody td {
        padding: 10px 16px;
        color: #343a40;
        border-bottom: 1px solid #f0f0f0;
        white-space: nowrap;
      }
      .dm-table-wrap tbody td.bold { font-weight: 600; }
      .dm-table-wrap tbody td.num { text-align: right; font-variant-numeric: tabular-nums; }
      .dm-table-wrap tbody td.center { text-align: center; }
      .dm-seg-badge {
        display: inline-block;
        padding: 2px 8px;
        border-radius: 2px;
        font-size: 0.75rem;
        font-weight: 700;
        color: white;
      }
      .seg-A { background: #074F57; }
      .seg-B { background: #077187; }
      .seg-C { background: #5ba3b0; }
      .dm-table-note {
        font-size: 0.78rem;
        color: #6c757d;
        margin-top: 12px;
        font-style: italic;
      }

      /* ── Override bslib card tabs to be clean ── */
      .dm-wrapper .card { border: none; box-shadow: none; background: transparent; }
      .dm-wrapper .nav-tabs { border-bottom: 2px solid #dee2e6; padding: 0 60px; background: white; }
      .dm-wrapper .nav-tabs .nav-link {
        font-size: 0.85rem;
        font-weight: 600;
        letter-spacing: 0.06em;
        color: #6c757d;
        border: none;
        padding: 14px 20px;
        border-bottom: 2px solid transparent;
        margin-bottom: -2px;
        border-radius: 0;
      }
      .dm-wrapper .nav-tabs .nav-link.active {
        color: #074F57;
        border-bottom-color: #077187;
        background: transparent;
      }
      .dm-wrapper .nav-tabs {
        border-bottom: 2px solid #dee2e6;
        padding: 0 60px;
        background: transparent;
      }
      .dm-wrapper .tab-content { background: transparent; padding: 0; }
      .dm-wrapper .card-body { padding: 0; }
    "))
    ),
    
    div(class = "dm-wrapper",
        
        # Hero
        div(class = "dm-hero",
            div(class = "dm-eyebrow", "Données & Méthodologie"),
            h1(class = "dm-hero-title", "Sources, traitement et aperçu du jeu de données")
        ),
        
        navset_card_tab(
          
          # ── TAB 1 : Jeux de données ──────────────────────────────────────────
          nav_panel(
            title = "Jeux de données",
            
            div(class = "dm-body",
                
                h2(class = "dm-section-title", "Sources de données"),
                tags$hr(class = "dm-section-rule"),
                
                # Dataset 1
                div(class = "dm-dataset-card",
                    tags$h5("Jeu de données 1"),
                    tags$h4("Régularité mensuelle des liaisons Intercités"),
                    tags$p(
                      "Ce jeu de données recense, pour chaque couple gare de départ – gare d'arrivée et pour chaque mois, les principaux indicateurs opérationnels : nombre de trains programmés, circulés et annulés, nombre de trains en retard,",
                      tags$strong("taux de régularité"),
                      "(proportion de trains arrivant avec moins de cinq minutes de retard), ainsi que le ratio de ponctualité. Il couvre la période de janvier 2014 à juillet 2025, pour un total de 5 609 observations."
                    ),
                    div(class = "dm-badge-row",
                        span(class = "dm-badge", "Jan 2014 – Juil 2025"),
                        span(class = "dm-badge", "5 609 observations"),
                        span(class = "dm-badge", "Mensuel"),
                        tags$a(
                          href = "https://ressources.data.sncf.com/explore/dataset/regularite-mensuelle-intercites/information/",
                          target = "_blank",
                          class = "dm-badge",
                          style = "text-decoration:none;",
                          "↗ data.sncf.com"
                        )
                    )
                ),
                
                # Dataset 2
                div(class = "dm-dataset-card",
                    tags$h5("Jeu de données 2"),
                    tags$h4("Fréquentation annuelle des gares"),
                    tags$p(
                      "Chaque gare y est identifiée par son nom, son code UIC, son code postal et sa direction régionale. Deux axes de segmentation sont renseignés : une segmentation marketing et une",
                      tags$strong("segmentation DRG"),
                      "(Document de Référence des Gares), qui classe chaque gare selon son rayonnement — A (national), B (régional), C (local). Pour chaque gare et chaque année, on dispose du nombre total de voyageurs et de non-voyageurs ayant fréquenté l'établissement."
                    ),
                    div(class = "dm-badge-row",
                        span(class = "dm-badge", "2015 – 2024"),
                        span(class = "dm-badge", "Annuel"),
                        span(class = "dm-badge", "Seg. DRG : A / B / C"),
                        tags$a(
                          href = "https://ressources.data.sncf.com/explore/dataset/frequentation-gares/information/",
                          target = "_blank",
                          class = "dm-badge",
                          style = "text-decoration:none;",
                          "↗ data.sncf.com"
                        )
                    )
                ),
                
                # Regional org
                div(class = "dm-info-card",
                    tags$h5("Organisation territoriale — 8 Directions Régionales des Gares (DRG)"),
                    div(class = "dm-directions-grid",
                        div(class = "dm-direction-item", "Gares d'Île-de-France"),
                        div(class = "dm-direction-item", "Hauts-de-France & Normandie"),
                        div(class = "dm-direction-item", "Grandes Gares Parisiennes"),
                        div(class = "dm-direction-item", "Grand Est"),
                        div(class = "dm-direction-item", "Bretagne & Pays de la Loire & Centre-Val-de-Loire"),
                        div(class = "dm-direction-item", "Auvergne-Rhône-Alpes & Bourgogne-Franche-Comté"),
                        div(class = "dm-direction-item", "Nouvelle-Aquitaine"),
                        div(class = "dm-direction-item", "Occitanie & Provence-Alpes-Côte d'Azur")
                    )
                )
            )
          ),
          
          # ── TAB 2 : Traitement ───────────────────────────────────────────────
          nav_panel(
            title = "Traitement",
            
            div(class = "dm-body",
                
                h2(class = "dm-section-title", "Pipeline de traitement"),
                tags$hr(class = "dm-section-rule"),
                
                tags$p(style = "font-size:0.92rem; color:#343a40; line-height:1.75; margin-bottom:28px;",
                       "La jointure des deux sources repose exclusivement sur le nom des gares, les codes UIC n'étant pas disponibles dans le jeu de données de régularité. Or les deux fichiers emploient des conventions orthographiques différentes — accentuation, ponctuation, abréviations — rendant toute correspondance directe impossible. Le nettoyage s'est déroulé en quatre étapes successives."
                ),
                
                # Step 1
                div(class = "dm-step",
                    div(class = "dm-step-number", "01"),
                    div(class = "dm-step-content",
                        tags$h4("Normalisation des noms de gares"),
                        tags$p("Une fonction de normalisation est appliquée uniformément aux deux jeux de données. Elle convertit chaque nom en majuscules, supprime les accents via translittération Latin-ASCII, remplace les espaces et apostrophes par des tirets, abrège", tags$code("SAINT"), "en", tags$code("ST"), ", et élimine les tirets redondants."),
                        div(class = "dm-code",
                            tags$pre(HTML(
                              '<span class="fn">normalize_station</span> <span class="op">&lt;-</span> <span class="kw">function</span>(x) {\n  x <span class="op">%&gt;%</span>\n    <span class="fn">toupper</span>() <span class="op">%&gt;%</span>\n    stringi::<span class="fn">stri_trans_general</span>(<span class="st">"Latin-ASCII"</span>) <span class="op">%&gt;%</span>\n    <span class="fn">str_replace_all</span>(<span class="st">" - "</span>, <span class="st">"-"</span>) <span class="op">%&gt;%</span>\n    <span class="fn">str_replace_all</span>(<span class="st">"[\'\ ]"</span>, <span class="st">"-"</span>) <span class="op">%&gt;%</span>\n    <span class="fn">str_replace_all</span>(<span class="st">"\\\\bSAINT\\\\b"</span>, <span class="st">"ST"</span>) <span class="op">%&gt;%</span>\n    <span class="fn">str_replace_all</span>(<span class="st">"-+"</span>, <span class="st">"-"</span>) <span class="op">%&gt;%</span>\n    <span class="fn">str_trim</span>()\n}'
                            ))
                        )
                    )
                ),
                
                # Step 2
                div(class = "dm-step",
                    div(class = "dm-step-number", "02"),
                    div(class = "dm-step-content",
                        tags$h4("Nettoyage du jeu de fréquentation"),
                        tags$p("Certaines gares partagent plusieurs noms alternatifs séparés par une barre oblique (ex.", tags$code("Brive / Brive-la-Gaillarde"), "). Ces entrées sont éclatées en lignes distinctes via", tags$code("separate_longer_delim()"), ", puis agrégées par nom normalisé. Les colonnes de fréquentation annuelle sont sommées, et la segmentation DRG de la première occurrence est conservée."),
                        div(class = "dm-code",
                            tags$pre(HTML(
                              '<span class="fn">df_freq</span> <span class="op">&lt;-</span> <span class="fn">read.csv</span>(<span class="st">"./data/frequentation-gares.csv"</span>, sep=<span class="st">";"</span>) <span class="op">%&gt;%</span>\n  <span class="fn">clean_names</span>() <span class="op">%&gt;%</span>\n  <span class="fn">separate_longer_delim</span>(nom_de_la_gare, delim = <span class="st">"/"</span>) <span class="op">%&gt;%</span>\n  <span class="fn">mutate</span>(nom_de_la_gare = <span class="fn">normalize_station</span>(nom_de_la_gare)) <span class="op">%&gt;%</span>\n  <span class="fn">group_by</span>(nom_de_la_gare) <span class="op">%&gt;%</span>\n  <span class="fn">summarise</span>(\n    <span class="fn">across</span>(<span class="fn">starts_with</span>(<span class="st">"total_voyageurs_"</span>), ~ <span class="fn">sum</span>(.x, na.rm = <span class="kw">TRUE</span>)),\n    segment_drg = <span class="fn">first</span>(segmentation_drg)\n  )'
                            ))
                        )
                    )
                ),
                
                # Step 3
                div(class = "dm-step",
                    div(class = "dm-step-number", "03"),
                    div(class = "dm-step-content",
                        tags$h4("Correction manuelle des cas résiduels"),
                        tags$p("Après normalisation automatique, 13 gares présentent encore une divergence entre les deux fichiers — par exemple", tags$code("ROUEN"), "face à", tags$code("ROUEN-RIVE-DROITE"), ", ou", tags$code("PARIS-VAUGIRARD"), "correspondant à", tags$code("PARIS-MONTPARNASSE"), ". Ces cas sont traités via un dictionnaire de correspondance appliqué avec", tags$code("recode()"), "."),
                        div(class = "dm-code",
                            tags$pre(HTML(
                              '<span class="fn">mapping</span> <span class="op">&lt;-</span> <span class="fn">c</span>(\n  <span class="st">"BRIVE"</span>           <span class="op">=</span> <span class="st">"BRIVE-LA-GAILLARDE"</span>,\n  <span class="st">"TOULOUSE"</span>        <span class="op">=</span> <span class="st">"TOULOUSE-MATABIAU"</span>,\n  <span class="st">"PARIS-NORD"</span>      <span class="op">=</span> <span class="st">"PARIS-GARE-DU-NORD"</span>,\n  <span class="st">"ROUEN"</span>           <span class="op">=</span> <span class="st">"ROUEN-RIVE-DROITE"</span>,\n  <span class="st">"PARIS-VAUGIRARD"</span> <span class="op">=</span> <span class="st">"PARIS-MONTPARNASSE"</span>,\n  <span class="cm">... <i>(13 cas au total)</i></span>\n)'
                            ))
                        )
                    )
                ),
                
                # Step 4
                div(class = "dm-step",
                    div(class = "dm-step-number", "04"),
                    div(class = "dm-step-content",
                        tags$h4("Jointure finale"),
                        tags$p("Les taux de régularité sont moyennés par triplet", tags$code("(départ, arrivée, date)"), "pour consolider les doublons éventuels, puis joints à gauche avec les données de fréquentation sur le nom normalisé de la gare de départ. Les observations sans segmentation DRG renseignée sont exclues."),
                        div(class = "dm-code",
                            tags$pre(HTML(
                              '<span class="fn">analysis_df</span> <span class="op">&lt;-</span> df_reg <span class="op">%&gt;%</span>\n  <span class="fn">group_by</span>(depart, arrivee, date) <span class="op">%&gt;%</span>\n  <span class="fn">summarise</span>(taux_reg = <span class="fn">mean</span>(taux_de_regularite, na.rm = <span class="kw">TRUE</span>), .groups = <span class="st">"drop"</span>) <span class="op">%&gt;%</span>\n  <span class="fn">left_join</span>(df_freq, by = <span class="fn">c</span>(<span class="st">"depart"</span> = <span class="st">"nom_de_la_gare"</span>)) <span class="op">%&gt;%</span>\n  <span class="fn">filter</span>(!<span class="fn">is.na</span>(segment_drg) <span class="op">&amp;</span> segment_drg <span class="op">!=</span> <span class="st">""</span>)'
                            ))
                        )
                    )
                )
            )
          ),
          
          # ── TAB 3 : Aperçu ───────────────────────────────────────────────────
          nav_panel(
            title = "Aperçu",
            
            div(class = "dm-body",
                
                h2(class = "dm-section-title", "Aperçu du jeu de données final"),
                tags$hr(class = "dm-section-rule"),
                
                tags$p(style = "font-size:0.92rem; color:#343a40; line-height:1.75; margin-bottom:24px;",
                       "Le tableau ci-dessous présente les premières observations du jeu de données consolidé, après jointure et nettoyage. Chaque ligne correspond à une liaison mensuelle entre deux gares."
                ),
                
                div(class = "dm-table-wrap",
                    tableOutput("dm_preview_table")
                ),
                
                tags$p(class = "dm-table-note",
                       "Les 8 premières observations — valeurs de fréquentation annuelle en nombre de voyageurs."
                )
            )
          )
        )
    )
  )
)

# Define server
server <- function(input, output, session) {
  # TRAITEMENT DES DONNEES
  normalize_station <- function(x) {
    x %>%
      toupper() %>%
      stringi::stri_trans_general("Latin-ASCII") %>%
      str_replace_all(" - ", "-") %>%
      str_replace_all("[' ]", "-") %>%
      str_replace_all("\\bSAINT\\b", "ST") %>%
      str_replace_all("-+", "-") %>%
      str_trim()
  }
  
  df_freq <- read.csv("./data/frequentation-gares.csv", sep=";", check.names=F) %>%
    clean_names() %>%
    separate_longer_delim(nom_de_la_gare, delim = "/") %>%
    mutate(nom_de_la_gare = normalize_station(nom_de_la_gare)) %>%
    group_by(nom_de_la_gare) %>%
    summarise(
      across(starts_with("total_voyageurs_"), ~ sum(.x, na.rm = TRUE)),
      segment_drg = first(segmentation_drg)
    ) %>%
    rename_with(~ str_replace(.x, "^total_voyageurs_", "voyageurs_"),
                starts_with("total_voyageurs_"))
  
  mapping <- c(
    "BRIVE"           = "BRIVE-LA-GAILLARDE",
    "TOULOUSE"        = "TOULOUSE-MATABIAU",
    "PARIS-NORD"      = "PARIS-GARE-DU-NORD",
    "PARIS-BERCY"     = "PARIS-BERCY-BOURGOGNE-PAYS-D-AUVERGNE",
    "LIMOGES"         = "LIMOGES-BENEDICTINS",
    "NICE-VILLE"      = "NICE",
    "BOULOGNE-VILLE"  = "BOULOGNE-SUR-MER",
    "CHERBOURG"       = "CHERBOURG-EN-COTENTIN",
    "ROUEN"           = "ROUEN-RIVE-DROITE",
    "ST-GERVAIS"      = "ST-GERVAIS-LES-BAINS-LE-FAYET",
    "LATOUR-DE-CAROL" = "LATOUR-DE-CAROL-ENVEITG",
    "LYON"            = "LYON-PART-DIEU",
    "PARIS-VAUGIRARD" = "PARIS-MONTPARNASSE"
  )
  
  df_reg <- read.csv("./data/regularite-mensuelle-intercites.csv", sep=";", check.names=F) %>%
    clean_names() %>%
    separate_longer_delim(c(depart, arrivee), delim = "/") %>%
    mutate(across(c(depart, arrivee), normalize_station)) %>%
    mutate(
      depart  = recode(depart,  !!!mapping),
      arrivee = recode(arrivee, !!!mapping)
    )
  
  analysis_df <- df_reg %>%
    group_by(depart, arrivee, date) %>%
    summarise(taux_reg = mean(taux_de_regularite, na.rm = TRUE), .groups = "drop") %>%
    left_join(df_freq, by = c("depart" = "nom_de_la_gare")) %>%
    filter(!is.na(segment_drg) & segment_drg != "")
  
  # GARES CHARTS
  
  # Chart 1 : Densité
  output$gares_densite <- renderPlot({
    df_voyageurs <- analysis_df %>%
      group_by(depart) %>%
      summarise(voyageurs_avg = mean(
        c_across(starts_with("voyageurs_")),
        na.rm = TRUE
      )) %>%
      filter(voyageurs_avg < input$mean_voyageurs_filter * 1e6) # Filtering
    
    mean_val <- mean(df_voyageurs$voyageurs_avg, na.rm = TRUE)
    
    ggplot(df_voyageurs, aes(x = voyageurs_avg)) +
      geom_area(stat = "density", fill = "#077187", alpha = 0.4, color = "#074F57", linewidth = 0.8) +
      scale_x_continuous(labels = function(x) format(x, big.mark = "\u202f", scientific = FALSE)) +
      labs(
        title    = "Densité de fréquentation des gares",
        subtitle = "Densité estimée - moyenne de fréquentation par gare",
        x = "Nombre moyen de voyageurs",
        y = "Densité"
      ) +
      theme_minimal() +
      theme(
        plot.title    = element_text(face = "bold", margin = margin(b = 6)),
        plot.subtitle = element_text(color = "grey50"),
        plot.margin   = margin(t = 10, r = 20, b = 10, l = 10),
        axis.title.x  = element_text(color = "grey50", margin = margin(t = 10)),
        axis.title.y  = element_text(color = "grey50", margin = margin(r = 10)),
        panel.grid.minor = element_blank()
      )
  })
  
  # Chart 2 : Évolution temporelle
  output$gares_evolution <- renderPlot({
    df_evolution <- analysis_df %>%
      group_by(depart) %>%
      summarise(across(starts_with("voyageurs_"), first)) %>%
      summarise(across(starts_with("voyageurs_"), mean, na.rm = TRUE)) %>%
      pivot_longer(cols = everything(),
                   names_to  = "annee",
                   values_to = "voyageurs_avg") %>%
      mutate(annee = as.integer(gsub("voyageurs_", "", annee))) %>%
      filter(annee >= input$date_range[1] & annee <= input$date_range[2])
    
    ggplot(df_evolution, aes(x = annee, y = voyageurs_avg)) +
      geom_area(fill = "#077187", alpha = 0.4, color = "#074F57", linewidth = 0.8) +
      geom_point(color = "#074F57", size = 3) +
      scale_x_continuous(breaks = input$date_range[1]:input$date_range[2]) +
      scale_y_continuous(labels = function(x) format(x, big.mark = "\u202f", scientific = FALSE)) +
      labs(
        title    = "Variation pluriannuelle de la fréquentation moyenne par gare",
        subtitle = "Moyenne annuelle calculée sur l'ensemble des gares",
        x = "Année",
        y = "Nombre moyen de voyageurs"
      ) +
      theme_minimal() +
      theme(
        plot.title    = element_text(face = "bold", margin = margin(b = 6)),
        plot.subtitle = element_text(color = "grey50"),
        plot.margin   = margin(t = 10, r = 20, b = 10, l = 10),
        axis.title.x  = element_text(color = "grey50", margin = margin(t = 10)),
        axis.title.y  = element_text(color = "grey50", margin = margin(r = 10)),
        panel.grid.minor = element_blank()
      )
  })
  
  # Chart 3 : Plus fréquentées
  output$gares_more_frequented <- renderPlot({
    df_top10 <- analysis_df %>%
      group_by(depart) %>%
      summarise(voyageurs_avg = mean(
        c_across(starts_with("voyageurs_")),
        na.rm = TRUE
      )) %>%
      filter(voyageurs_avg < input$mean_voyageurs_filter * 1e6) %>% # Filtering
      arrange(desc(voyageurs_avg)) %>%
      mutate(
        total     = sum(voyageurs_avg),
        pct       = voyageurs_avg / total * 100,
        top10_pct = sum(pct[1:10])
      ) %>%
      slice_head(n = 10) %>%
      mutate(depart = reorder(depart, voyageurs_avg))
    
    top10_share <- round(df_top10$top10_pct[1], 1)
    
    ggplot(df_top10, aes(x = depart, y = voyageurs_avg)) +
      geom_col(fill = "#077187", alpha = 0.85, width = 0.7) +
      geom_text(aes(label = paste0(round(pct, 1), "%")),
                hjust = -0.15, color = "#074F57", size = 3.5, fontface = "bold") +
      coord_flip() +
      scale_y_continuous(
        labels = function(x) format(x, big.mark = "\u202f", scientific = FALSE),
        expand = expansion(mult = c(0, 0.15))
      ) +
      labs(
        title    = "Hiérarchie des pôles d'affluence du réseau Intercités (2018–2024)",
        subtitle = paste0("Ces gares représentent ", top10_share, "% du trafic total"),
        x = NULL,
        y = "Nombre moyen de voyageurs"
      ) +
      theme_minimal() +
      theme(
        plot.title    = element_text(face = "bold", margin = margin(b = 6)),
        plot.subtitle = element_text(color = "grey50"),
        plot.margin   = margin(t = 10, r = 20, b = 10, l = 10),
        axis.title.x  = element_text(color = "grey50", margin = margin(t = 10)),
        axis.title.y  = element_text(color = "grey50", margin = margin(r = 10)),
        panel.grid.minor   = element_blank(),
        panel.grid.major.y = element_blank()
      )
  })
  
  # LIAISONS CHARTS
  
  # Chart 1 : Densité
  analysis_df_filtered <- reactive({
    analysis_df %>%
      mutate(
        voyageurs_avg = rowMeans(
          across(starts_with("voyageurs_")),
          na.rm = TRUE
        )
      ) %>%
      filter(
        voyageurs_avg >= input$mean_voyageurs_filter_liaisons[1] * 1e6,
        voyageurs_avg <= input$mean_voyageurs_filter_liaisons[2] * 1e6
      )
  })
  
  output$liaisons_densite <- renderPlot({
    mean_val <- mean(analysis_df_filtered()$taux_reg, na.rm = TRUE)
    
    ggplot(analysis_df_filtered(), aes(x = taux_reg)) +
      geom_area(stat = "density", fill = "#077187", alpha = 0.4, color = "#074F57", linewidth = 0.8) +
      scale_x_continuous(labels = function(x) paste0(x, "%")) +
      labs(
        title    = "Répartition statistique des taux de ponctualité",
        subtitle = "Densité de régularité des gares",
        x = "Taux de régularité",
        y = "Densité"
      ) +
      theme_minimal() +
      theme(
        plot.title    = element_text(face = "bold", margin = margin(b = 6)),
        plot.subtitle = element_text(color = "grey50"),
        plot.margin   = margin(t = 10, r = 20, b = 10, l = 10),
        axis.title.x  = element_text(color = "grey50", margin = margin(t = 10)),
        axis.title.y  = element_text(color = "grey50", margin = margin(r = 10)),
        panel.grid.minor = element_blank()
      )
  })
  
  # Chart 2 : Évolution temporelle
  output$liaisons_evolution <- renderPlot({
    df_evolution_reg <- analysis_df %>%
      mutate(date = as.Date(paste0(date, "-01"))) %>%
      filter(
        date >= input$date_range_liaisons[1],
        date <= input$date_range_liaisons[2]
      ) %>%
      group_by(date) %>%
      summarise(
        taux_reg_avg = mean(taux_reg, na.rm = TRUE),
        .groups = "drop"
      )
    
    ggplot(df_evolution_reg, aes(x = date, y = taux_reg_avg)) +
      geom_area(fill = "#077187", alpha = 0.4, color = "#074F57", linewidth = 0.8) +
      geom_point(color = "#074F57", size = 2) +
      scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
      scale_y_continuous(
        labels = function(x) paste0(x, "%"),
        limits = c(0, 100)
      ) +
      labs(
        title    = "Évolution du taux de régularité moyen des gares de départ",
        subtitle = "Moyenne mensuelle calculée sur l'ensemble des liaisons Intercités",
        x = "Date",
        y = "Taux de régularité moyen"
      ) +
      theme_minimal() +
      theme(
        plot.title    = element_text(face = "bold", margin = margin(b = 6)),
        plot.subtitle = element_text(color = "grey50"),
        plot.margin   = margin(t = 10, r = 20, b = 10, l = 10),
        axis.title.x  = element_text(color = "grey50", margin = margin(t = 10)),
        axis.title.y  = element_text(color = "grey50", margin = margin(r = 10)),
        panel.grid.minor = element_blank()
      )
  })
  
  # Chart 3 : Plus régulières
  df_reg_liaison <- reactive({
    analysis_df_filtered() %>%
    group_by(depart, arrivee) %>%
    summarise(taux_reg = mean(taux_reg, na.rm = TRUE), .groups = "drop") %>%
    mutate(liaison = paste0(depart, " → ", arrivee))
  })
  
  output$liaisons_more_regular <- renderPlot({
    # Top 10
    df_top10_reg <- df_reg_liaison() %>%
      arrange(desc(taux_reg)) %>%
      slice_head(n = 10) %>%
      mutate(liaison = reorder(liaison, taux_reg))
    
    ggplot(df_top10_reg, aes(x = liaison, y = taux_reg)) +
      geom_col(fill = "#077187", alpha = 0.85, width = 0.7) +
      geom_text(aes(label = paste0(format(round(taux_reg, 1), nsmall = 1), "%")),
                hjust = -0.15, color = "#074F57", size = 3.5, fontface = "bold") +
      coord_flip() +
      scale_y_continuous(
        limits = c(0, 105),
        expand = expansion(mult = c(0, 0.05))
      ) +
      labs(
        title    = "Top des liaisons les plus régulières",
        subtitle = "Classement par taux de régularité moyen sur l'ensemble de la période",
        x = NULL,
        y = "Taux de régularité (%)"
      ) +
      theme_minimal() +
      theme(
        plot.title    = element_text(face = "bold", margin = margin(b = 6)),
        plot.subtitle = element_text(color = "grey50"),
        plot.margin   = margin(t = 10, r = 20, b = 10, l = 10),
        axis.title.x  = element_text(color = "grey50", margin = margin(t = 10)),
        axis.title.y  = element_text(color = "grey50", margin = margin(r = 10)),
        panel.grid.minor   = element_blank(),
        panel.grid.major.y = element_blank()
      )
  })
  
  # Chart 4 : Moins régulières
  output$liaisons_less_regular <- renderPlot({
    df_bot10_reg <- df_reg_liaison() %>%
      arrange(taux_reg) %>%
      slice_head(n = 10) %>%
      mutate(liaison = reorder(liaison, taux_reg))
    
    ggplot(df_bot10_reg, aes(x = liaison, y = taux_reg)) +
      geom_col(fill = "#077187", alpha = 0.85, width = 0.7) +
      geom_text(aes(label = paste0(format(round(taux_reg, 1), nsmall = 1), "%")),
                hjust = -0.15, color = "#074F57", size = 3.5, fontface = "bold") +
      coord_flip() +
      scale_y_continuous(
        limits = c(0, 105),
        expand = expansion(mult = c(0, 0.05))
      ) +
      labs(
        title    = "Top des liaisons les moins régulières",
        subtitle = "Classement par taux de régularité moyen sur l'ensemble de la période",
        x = NULL,
        y = "Taux de régularité (%)"
      ) +
      theme_minimal() +
      theme(
        plot.title    = element_text(face = "bold", margin = margin(b = 6)),
        plot.subtitle = element_text(color = "grey50"),
        plot.margin   = margin(t = 10, r = 20, b = 10, l = 10),
        axis.title.x  = element_text(color = "grey50", margin = margin(t = 10)),
        axis.title.y  = element_text(color = "grey50", margin = margin(r = 10)),
        panel.grid.minor   = element_blank(),
        panel.grid.major.y = element_blank()
      )
  })
  
  # CORRELATION CHARTS
  
  # Chart 1 : Régression linéaire
  df_corr <- reactive({
    analysis_df %>%
    group_by(depart, arrivee) %>%
    summarise(
      taux_reg      = mean(taux_reg, na.rm = TRUE),
      voyageurs_avg = mean(c(first(voyageurs_2018), first(voyageurs_2019),
                             first(voyageurs_2020), first(voyageurs_2021),
                             first(voyageurs_2022), first(voyageurs_2023),
                             first(voyageurs_2024)), na.rm = TRUE),
      .groups = "drop"
    ) %>%
    filter(
      voyageurs_avg >= input$mean_voyageurs_filter_correlation[1] * 1e6,
      voyageurs_avg <= input$mean_voyageurs_filter_correlation[2] * 1e6
    )
  })
  
  output$correlation_linear <- renderPlot({
    ggplot(df_corr(), aes(x = voyageurs_avg, y = taux_reg)) +
      geom_point(color = "#077187", alpha = 0.7, size = 3) +
      geom_smooth(method = "lm", color = "#074F57", fill = "#077187",
                  alpha = 0.15, linewidth = 0.8) +
      scale_x_continuous(labels = function(x) format(x, big.mark = "\u202f", scientific = FALSE)) +
      labs(
        title    = "Relation entre fréquentation de la gare de départ et taux de régularité",
        subtitle = "Chaque point représente une liaison - droite de régression linéaire en fond",
        x = "Nombre moyen de voyageurs de la gare de départ",
        y = "Taux de régularité (%)"
      ) +
      theme_minimal() +
      theme(
        plot.title    = element_text(face = "bold", margin = margin(b = 6)),
        plot.subtitle = element_text(color = "grey50"),
        plot.margin   = margin(t = 10, r = 20, b = 10, l = 10),
        axis.title.x  = element_text(color = "grey50", margin = margin(t = 10)),
        axis.title.y  = element_text(color = "grey50", margin = margin(r = 10)),
        panel.grid.minor = element_blank()
      )
  })
  
  # Chart 2 : Évolution du coefficient de corrélation
  df_corr_evol <- reactive({
    
    req(input$date_range_liaisons)
    
    df <- analysis_df %>%
      mutate(date = as.Date(paste0(date, "-01")))
    
    df <- df %>%
      filter(
        date >= input$date_range_correlation[1],
        date <= input$date_range_correlation[2]
      )
    
    df %>%
      pivot_longer(
        cols = starts_with("voyageurs_"),
        names_to = "annee",
        values_to = "voyageurs"
      ) %>%
      mutate(
        annee = readr::parse_number(annee)
      ) %>%
      filter(year(date) == annee) %>%
      group_by(date) %>%
      summarise(
        tau = cor(voyageurs, taux_reg,
                  method = "kendall",
                  use = "complete.obs"),
        .groups = "drop"
      )
  })
  
  output$correlation_evolution <- renderPlot({
    ggplot(df_corr_evol(), aes(x = date, y = tau)) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey60", linewidth = 0.6) +
      geom_area(fill = "#077187", alpha = 0.4, color = "#074F57", linewidth = 0.8) +
      geom_point(color = "#074F57", size = 2) +
      scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
      scale_y_continuous(limits = c(-1, 1)) +
      labs(
        title    = "Évolution du coefficient de corrélation de Kendall",
        subtitle = "Evalue la corrélation entre régularité et fréquentation des gares",
        x = "Date",
        y = "τ de Kendall"
      ) +
      theme_minimal() +
      theme(
        plot.title    = element_text(face = "bold", margin = margin(b = 6)),
        plot.subtitle = element_text(color = "grey50"),
        plot.margin   = margin(t = 10, r = 20, b = 10, l = 10),
        axis.title.x  = element_text(color = "grey50", margin = margin(t = 10)),
        axis.title.y  = element_text(color = "grey50", margin = margin(r = 10)),
        panel.grid.minor = element_blank()
      )
  })
  
  
  # Point 3 : Corrélation de Kendall
  output$correlation_kendall <- renderTable({
    
    df <- df_corr()
    req(nrow(df) > 0)
    
    kendall_test <- cor.test(
      df$voyageurs_avg,
      df$taux_reg,
      method = "kendall"
    )
    
    broom::tidy(kendall_test) %>%
      select(
        `τ de Kendall`  = estimate,
        `Statistique z` = statistic,
        `p-value`       = p.value,
        Méthode         = method
      ) %>%
      mutate(across(where(is.numeric), ~ round(.x, 4)))
  })
  
  # DATA AND METHODS
  
  output$dm_preview_table <- renderTable({
    analysis_df %>%
      head(8) %>%
      select(
        Départ       = depart,
        Arrivée      = arrivee,
        Date         = date,
        `Régularité` = taux_reg,
        `Voy. 2023`  = voyageurs_2023,
        `Voy. 2024`  = voyageurs_2024,
        `Seg. DRG`   = segment_drg
      ) %>%
      mutate(
        `Régularité` = paste0(round(`Régularité`, 1), "%"),
        across(starts_with("Voy."), ~ format(.x, big.mark = "\u202f", scientific = FALSE))
      )
  }, striped = TRUE, hover = TRUE, bordered = FALSE, spacing = "m",
  width = "100%", align = "llcrrrc")
}

# Run app
shinyApp(ui = ui, server = server)