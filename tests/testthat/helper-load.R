if (!"slurmwiz" %in% loadedNamespaces()) {
  pkgload::load_all(".", export_all = FALSE, helpers = FALSE, quiet = TRUE)
}
