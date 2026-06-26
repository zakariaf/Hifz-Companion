// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The bundled, read-only projection of `docs/science/CLAIMS.md` (groups A–J).
///
/// This is the **structural** register — id, group, evidence grade(s), and the
/// named source(s) — shipped inside the app binary (offline, no network, no AI;
/// science doc §2). The plain headline and any honest caveat for each row are
/// localized at the View layer keyed by the claim id (`science_copy.dart`); the
/// grade → confidence wording is the E10 `CertaintyLabel`. Authoring lives in
/// `docs/science/CLAIMS.md`; the `tool/check_claims_coverage.dart` gate proves
/// this projection stays faithful to it (every id, every grade), and the parser
/// rejects an unknown grade as a release-blocking defect rather than rendering a
/// fallback.
///
/// Grades use the bare register tags (`MA`/`RCT`/`EXP`/`CS`/`OBS`/`TEXT`/`TRAD`);
/// `C-048`'s "TRAD-equivalent project rule" is carried as `TRAD` (the app's own
/// offline/no-microphone guarantee), with its on-device source naming it plainly.
const String claimsRegisterJson = r'''
{
  "version": 1,
  "claims": [
    {
      "id": "C-001", "group": "A", "grades": ["EXP", "CS"],
      "sources": [
        {"label": "Murre & Dros, 2015 — PLOS ONE", "url": "https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644"},
        {"label": "Ebbinghaus, 1885", "url": "https://psychclassics.yorku.ca/Ebbinghaus/index.htm"}
      ]
    },
    {
      "id": "C-002", "group": "A", "grades": ["EXP", "TEXT"],
      "sources": [
        {"label": "Nelson, 1985 — JEP: LMC", "url": "https://psycnet.apa.org/record/1986-11014-001"},
        {"label": "Murre & Chessa, 2022 — Psychonomic Bulletin & Review", "url": "https://link.springer.com/article/10.3758/s13423-022-02172-3"}
      ]
    },
    {
      "id": "C-003", "group": "A", "grades": ["EXP"],
      "sources": [
        {"label": "Henson et al., 1996 — QJEP", "url": "https://journals.sagepub.com/doi/10.1080/713755612"},
        {"label": "Solway et al., 2012 — Memory & Cognition", "url": "https://pmc.ncbi.nlm.nih.gov/articles/PMC3282556/"}
      ]
    },
    {
      "id": "C-004", "group": "A", "grades": ["TEXT", "MA"],
      "sources": [
        {"label": "Diekelmann & Born, 2010 — Nature Reviews Neuroscience", "url": "https://doi.org/10.1038/nrn2762"},
        {"label": "Berres & Erdfelder, 2021 — Psychological Bulletin", "url": "https://doi.org/10.1037/bul0000350"}
      ]
    },
    {
      "id": "C-005", "group": "A", "grades": ["OBS"],
      "sources": [
        {"label": "Bahrick, 1984 — JEP: General", "url": "https://pubmed.ncbi.nlm.nih.gov/6242406/"}
      ]
    },
    {
      "id": "C-006", "group": "B", "grades": ["MA"],
      "sources": [
        {"label": "Donovan & Radosevich, 1999 — Journal of Applied Psychology", "url": "https://psycnet.apa.org/doi/10.1037/0021-9010.84.5.795"},
        {"label": "Dunlosky et al., 2013 — Psychological Science in the Public Interest", "url": "https://journals.sagepub.com/doi/10.1177/1529100612453266"}
      ]
    },
    {
      "id": "C-007", "group": "B", "grades": ["MA", "EXP"],
      "sources": [
        {"label": "Cepeda et al., 2006 — Psychological Bulletin", "url": "https://www.yorku.ca/ncepeda/publications/CPVWR2006.html"},
        {"label": "Cepeda et al., 2008 — Psychological Science", "url": "https://doi.org/10.1111/j.1467-9280.2008.02209.x"}
      ]
    },
    {
      "id": "C-008", "group": "B", "grades": ["CS"],
      "sources": [
        {"label": "Bahrick et al., 1993 — Psychological Science", "url": "https://journals.sagepub.com/doi/10.1111/j.1467-9280.1993.tb00571.x"}
      ]
    },
    {
      "id": "C-009", "group": "B", "grades": ["EXP"],
      "sources": [
        {"label": "Cepeda et al., 2009 — Experimental Psychology", "url": "https://doi.org/10.1027/1618-3169.56.4.236"}
      ]
    },
    {
      "id": "C-013", "group": "B", "grades": ["EXP"],
      "sources": [
        {"label": "Mazza et al., 2016 — Psychological Science", "url": "https://doi.org/10.1177/0956797616659930"},
        {"label": "Bell et al., 2014 — Memory", "url": "https://doi.org/10.1080/09658211.2013.778294"}
      ]
    },
    {
      "id": "C-010", "group": "C", "grades": ["TEXT"],
      "sources": [
        {"label": "Open Spaced Repetition — The Algorithm", "url": "https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm"},
        {"label": "Expertium — FSRS Algorithm", "url": "https://expertium.github.io/Algorithm.html"}
      ]
    },
    {
      "id": "C-011", "group": "C", "grades": ["TEXT", "EXP"],
      "sources": [
        {"label": "Woźniak — Two components of memory", "url": "https://supermemo.guru/wiki/Two_components_of_memory"},
        {"label": "Wheeler et al., 2003 — Memory", "url": "https://pubmed.ncbi.nlm.nih.gov/14982124/"}
      ]
    },
    {
      "id": "C-012", "group": "C", "grades": ["TEXT", "EXP"],
      "sources": [
        {"label": "Bjork & Bjork, 2011 — Desirable difficulties", "url": "https://www.unh.edu/teaching-learning-resource-hub/sites/default/files/media/2023-06/itow-introducing-desirable-difficulties-into-practice-and-instruction-bjork-and-bjork.pdf"},
        {"label": "Pashler et al., 2003 — JEP: LMC", "url": "https://doi.org/10.1037/0278-7393.29.6.1051"}
      ]
    },
    {
      "id": "C-014", "group": "C", "grades": ["OBS"],
      "sources": [
        {"label": "Settles & Meeder, 2016 — ACL", "url": "https://research.duolingo.com/papers/settles.acl16.pdf"}
      ]
    },
    {
      "id": "C-018", "group": "D", "grades": ["MA", "EXP"],
      "sources": [
        {"label": "Rowland, 2014 — Psychological Bulletin", "url": "https://www.researchgate.net/publication/264988491_The_Effect_of_Testing_Versus_Restudy_on_Retention_A_Meta-Analytic_Review_of_the_Testing_Effect"},
        {"label": "Roediger & Karpicke, 2006 — Psychological Science", "url": "https://journals.sagepub.com/doi/10.1111/j.1467-9280.2006.01693.x"}
      ]
    },
    {
      "id": "C-019", "group": "D", "grades": ["EXP"],
      "sources": [
        {"label": "Karpicke & Roediger, 2008 — Science", "url": "https://www.science.org/doi/abs/10.1126/science.1152408"}
      ]
    },
    {
      "id": "C-020", "group": "D", "grades": ["MA", "EXP"],
      "sources": [
        {"label": "Rowland, 2014 — Psychological Bulletin", "url": "https://www.researchgate.net/publication/264988491_The_Effect_of_Testing_Versus_Restudy_on_Retention_A_Meta-Analytic_Review_of_the_Testing_Effect"},
        {"label": "Butler, Karpicke & Roediger, 2007 — JEP: Applied", "url": "https://pubmed.ncbi.nlm.nih.gov/18194050/"}
      ]
    },
    {
      "id": "C-021", "group": "D", "grades": ["MA", "TRAD"], "needsScholarlyReview": true,
      "sources": [
        {"label": "Rowland, 2014 — Psychological Bulletin", "url": "https://www.researchgate.net/publication/264988491_The_Effect_of_Testing_Versus_Restudy_on_Retention_A_Meta-Analytic_Review_of_the_Testing_Effect"},
        {"label": "Mohamad & Mohamad — Talaqqī & Mushāfaha", "url": "https://www.academia.edu/81052538/Concept_and_Execution_of_Talaqqi_and_Musyafahah_Method_in_Learning_Al_Quran"}
      ]
    },
    {
      "id": "C-022", "group": "D", "grades": ["EXP", "OBS"],
      "sources": [
        {"label": "Karpicke & Blunt, 2011 — Science", "url": "https://www.science.org/doi/10.1126/science.1199327"},
        {"label": "Karpicke, Butler & Roediger, 2009 — Memory", "url": "https://www.tandfonline.com/doi/abs/10.1080/09658210802647009"}
      ]
    },
    {
      "id": "C-026", "group": "E", "grades": ["CS"],
      "sources": [
        {"label": "McGeoch, 1932 — Psychological Review", "url": "https://psycnet.apa.org/record/1933-00060-001"},
        {"label": "Underwood, 1957 — Psychological Review", "url": "https://psycnet.apa.org/record/1958-01239-001"}
      ]
    },
    {
      "id": "C-027", "group": "E", "grades": ["CS"],
      "sources": [
        {"label": "McGeoch & McDonald, 1931 — American Journal of Psychology", "url": "https://www.jstor.org/stable/1415159"},
        {"label": "Osgood, 1949 — Psychological Review", "url": "https://psycnet.apa.org/record/1949-03900-001"}
      ]
    },
    {
      "id": "C-028", "group": "E", "grades": ["EXP"],
      "sources": [
        {"label": "Kornell & Bjork, 2008 — Psychological Science", "url": "https://journals.sagepub.com/doi/10.1111/j.1467-9280.2008.02127.x"},
        {"label": "Birnbaum et al., 2013 — Memory & Cognition", "url": "https://link.springer.com/article/10.3758/s13421-012-0272-7"},
        {"label": "Carvalho & Goldstone, 2014 — Memory & Cognition", "url": "https://link.springer.com/article/10.3758/s13421-013-0371-0"}
      ]
    },
    {
      "id": "C-029", "group": "E", "grades": ["EXP"],
      "sources": [
        {"label": "Anderson, Bjork & Bjork, 1994 — JEP: LMC", "url": "https://bjorklab.psych.ucla.edu/wp-content/uploads/sites/13/2016/07/Anderson_RBjork_EBjork_1994.pdf"}
      ]
    },
    {
      "id": "C-030", "group": "E", "grades": ["CS", "TRAD", "OBS"], "needsScholarlyReview": true,
      "sources": [
        {"label": "Underwood, 1957 — Psychological Review", "url": "https://psycnet.apa.org/record/1958-01239-001"},
        {"label": "GetItQan — What is Mutashabihat", "url": "https://getitqan.com/blog/what-is-mutashabihat"},
        {"label": "Mohd Yusoff et al., 2022 — IJARBSS", "url": "https://hrmars.com/papers_submitted/10821/tahfiz-education-in-malaysia-issues-and-problems-in-memorising-quranic-mutashabihat-verses-and-its-solution.pdf"}
      ]
    },
    {
      "id": "C-031", "group": "F", "grades": ["CS"],
      "sources": [
        {"label": "Lashley, 1951 (Rosenbaum et al., 2007)", "url": "https://www.academia.edu/4453729/The_problem_of_serial_order_in_behavior_Lashley_s_legacy"},
        {"label": "Henson et al., 1996 — QJEP", "url": "https://journals.sagepub.com/doi/10.1080/713755612"},
        {"label": "Miller, 1956 — Psychological Review", "url": "https://en.wikipedia.org/wiki/The_Magical_Number_Seven,_Plus_or_Minus_Two"}
      ]
    },
    {
      "id": "C-032", "group": "F", "grades": ["CS"],
      "sources": [
        {"label": "Hebb, 1961 (Szmalec et al., 2009 — QJEP)", "url": "https://pubmed.ncbi.nlm.nih.gov/18785073/"}
      ]
    },
    {
      "id": "C-033", "group": "F", "grades": ["EXP"],
      "sources": [
        {"label": "Ryan, 1969 — QJEP", "url": "https://journals.sagepub.com/doi/10.1080/14640746908400206"},
        {"label": "Cowan & Elliott, 2022 — JEP: LMC", "url": "https://pmc.ncbi.nlm.nih.gov/articles/PMC10028597/"},
        {"label": "Murre & Dros, 2015 — PLOS ONE", "url": "https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644"}
      ]
    },
    {
      "id": "C-023", "group": "G", "grades": ["EXP"],
      "sources": [
        {"label": "Rawson & Dunlosky, 2011 — JEP: General", "url": "https://www.academia.edu/13564381/"},
        {"label": "Rawson et al., 2018 — JEP: Applied", "url": "https://pubmed.ncbi.nlm.nih.gov/29431462/"}
      ]
    },
    {
      "id": "C-024", "group": "G", "grades": ["EXP", "OBS"],
      "sources": [
        {"label": "Logan, 1988; Newell & Rosenbloom, 1981 — Power law of practice", "url": "https://en.wikipedia.org/wiki/Power_law_of_practice"},
        {"label": "Bahrick, 1984 — JEP: General", "url": "https://pubmed.ncbi.nlm.nih.gov/6242406/"}
      ]
    },
    {
      "id": "C-025", "group": "G", "grades": ["OBS"],
      "sources": [
        {"label": "Bahrick, 1984 — JEP: General", "url": "https://pubmed.ncbi.nlm.nih.gov/6242406/"},
        {"label": "Bahrick & Hall, 1991 — JEP: General", "url": "https://www.semanticscholar.org/paper/5bac650cdedcbf14cb4ebd2a88cc3e793ba81b55"}
      ]
    },
    {
      "id": "C-034", "group": "H", "grades": ["TRAD"], "needsScholarlyReview": true,
      "sources": [
        {"label": "IslamicTuition — Sabaq, Sabqi, Manzil", "url": "https://islamictuition.us/blog/sabaq-sabqi-manzil-hifz-revision-system/"},
        {"label": "Ilmify — Murājaʿa", "url": "https://ilmify.app/blog/what-is-murajaah-quran-revision/"}
      ]
    },
    {
      "id": "C-035", "group": "H", "grades": ["TRAD"], "needsScholarlyReview": true,
      "sources": [
        {"label": "Ṣaḥīḥ al-Bukhārī 5032", "url": "https://sunnah.com/bukhari:5032"},
        {"label": "Ṣaḥīḥ Muslim 791", "url": "https://hadeethenc.com/en/browse/hadith/5907"}
      ]
    },
    {
      "id": "C-036", "group": "H", "grades": ["TRAD"], "needsScholarlyReview": true,
      "sources": [
        {"label": "Manzil — seven manāzil of Ḥamzah az-Zayyāt", "url": "https://en.wikipedia.org/wiki/Manzil"}
      ]
    },
    {
      "id": "C-037", "group": "H", "grades": ["MA", "TEXT"],
      "sources": [
        {"label": "Cepeda et al., 2006 — Psychological Bulletin", "url": "https://www.yorku.ca/ncepeda/publications/CPVWR2006.html"},
        {"label": "Expertium — FSRS Algorithm", "url": "https://expertium.github.io/Algorithm.html"}
      ]
    },
    {
      "id": "C-038", "group": "H", "grades": ["TRAD"], "needsScholarlyReview": true,
      "sources": [
        {"label": "Mohamad & Mohamad — Talaqqī & Mushāfaha", "url": "https://www.academia.edu/81052538/Concept_and_Execution_of_Talaqqi_and_Musyafahah_Method_in_Learning_Al_Quran"},
        {"label": "Ijāzah / sanad", "url": "https://en.wikipedia.org/wiki/Ijazah"}
      ]
    },
    {
      "id": "C-039", "group": "H", "grades": ["TRAD"], "needsScholarlyReview": true,
      "sources": [
        {"label": "Ṣaḥīḥ al-Bukhārī 4998", "url": "https://sunnah.com/bukhari:4998"}
      ]
    },
    {
      "id": "C-040", "group": "H", "grades": ["TRAD"], "needsScholarlyReview": true,
      "sources": [
        {"label": "Tarteel — The Mauritanian Method", "url": "https://tarteel.ai/blog/quran-memorization-techniques-the-mauritanian-method/"},
        {"label": "HTMTQ — The Takrār Method", "url": "https://medium.com/how-to-memorise-the-quran/the-takrar-method-of-memorisation-in-madinah-al-munawwarah-schedules-62fe4a8d1179"},
        {"label": "HTMTQ — The Ottoman Method", "url": "https://howtomemorisethequran.com/the-ottoman-hifz-method/"}
      ]
    },
    {
      "id": "C-041", "group": "I", "grades": ["MA", "EXP"],
      "sources": [
        {"label": "Deci, Koestner & Ryan, 1999 — Psychological Bulletin", "url": "https://home.ubalt.edu/tmitch/642/articles%20syllabus/Deci%20Koestner%20Ryan%20meta%20IM%20psy%20bull%2099.pdf"},
        {"label": "Lepper, Greene & Nisbett, 1973 — JPSP", "url": "https://psycnet.apa.org/record/1974-10497-001"},
        {"label": "Mekler et al., 2017 — Computers in Human Behavior", "url": "https://www.sciencedirect.com/science/article/abs/pii/S0747563215301229"}
      ]
    },
    {
      "id": "C-042", "group": "I", "grades": ["OBS"],
      "sources": [
        {"label": "Lally et al., 2010 — European Journal of Social Psychology", "url": "https://onlinelibrary.wiley.com/doi/10.1002/ejsp.674"}
      ]
    },
    {
      "id": "C-043", "group": "I", "grades": ["MA", "TEXT"],
      "sources": [
        {"label": "Peng et al., 2023 — Frontiers in Psychology", "url": "https://pmc.ncbi.nlm.nih.gov/articles/PMC10568480/"},
        {"label": "Tangney et al., 2007 — Annual Review of Psychology", "url": "https://www.its.caltech.edu/~squartz/Tangney.pdf"}
      ]
    },
    {
      "id": "C-044", "group": "I", "grades": ["MA", "TEXT"],
      "sources": [
        {"label": "Zainuddin et al., 2023 — ETR&D", "url": "https://link.springer.com/article/10.1007/s11423-023-10337-7"},
        {"label": "Ryan & Deci, 2000 — American Psychologist", "url": "https://pubmed.ncbi.nlm.nih.gov/11392867/"}
      ]
    },
    {
      "id": "C-045", "group": "I", "grades": ["TRAD", "CS"], "needsScholarlyReview": true,
      "sources": [
        {"label": "Ṣaḥīḥ al-Bukhārī 1", "url": "https://sunnah.com/bukhari:1"},
        {"label": "Ṣaḥīḥ Muslim 1907", "url": "https://sunnah.com/muslim:1907"},
        {"label": "Allport & Ross, 1967 — JPSP", "url": "https://psycnet.apa.org/doiLanding?doi=10.1037/h0021212"}
      ]
    },
    {
      "id": "C-016", "group": "J", "grades": ["EXP", "TRAD"],
      "sources": [
        {"label": "Cepeda et al., 2009 — Experimental Psychology", "url": "https://doi.org/10.1027/1618-3169.56.4.236"},
        {"label": "Ṣaḥīḥ al-Bukhārī 4998 (al-ʿarḍa al-akhīra)", "url": "https://sunnah.com/bukhari:4998"}
      ]
    },
    {
      "id": "C-017", "group": "J", "grades": ["TEXT"],
      "sources": [
        {"label": "Open Spaced Repetition — The optimal retention", "url": "https://github.com/open-spaced-repetition/fsrs4anki/wiki/The-optimal-retention"},
        {"label": "Expertium — FSRS Algorithm", "url": "https://expertium.github.io/Algorithm.html"}
      ]
    },
    {
      "id": "C-046", "group": "J", "grades": ["TRAD"], "needsScholarlyReview": true,
      "sources": [
        {"label": "Mohamad & Mohamad — Talaqqī & Mushāfaha", "url": "https://www.academia.edu/81052538/Concept_and_Execution_of_Talaqqi_and_Musyafahah_Method_in_Learning_Al_Quran"}
      ]
    },
    {
      "id": "C-047", "group": "J", "grades": ["OBS"],
      "sources": [
        {"label": "American Press Institute — Building credibility through transparency", "url": "https://americanpressinstitute.org/transparency-credibility/"}
      ]
    },
    {
      "id": "C-048", "group": "J", "grades": ["TRAD"],
      "sources": [
        {"label": "Hifz Companion design — offline, no microphone (PRD C1, C2)", "url": null}
      ]
    }
  ]
}
''';
