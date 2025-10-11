df <- read.csv("raw-data.csv",
  sep = ";", stringsAsFactors = FALSE, check.names = FALSE
)

# neteja de noms: tot el que no sigui lletra o dígit → underscore
names(df) <- gsub("[^A-Za-z0-9]+", "_", names(df))
names(df) <- gsub("_+", "_", names(df))
names(df) <- gsub("^_|_$", "", names(df))

# variables que no siguin numèriques que calen convertir
cat_vars <- c(
  "Marital_status",
  "Application_mode",
  "Course",
  "Daytime_evening_attendance",
  "Previous_qualification",
  "Previous_qualification_grade",
  "Nacionality",
  "Mother_s_occupation",
  "Father_s_occupation",
  "Displaced",
  "Educational_special_needs",
  "Debtor",
  "Tuition_fees_up_to_date",
  "Gender",
  "Scholarship_holder",
  "International",
  "Target"
)

# les convertim en factors
for (v in cat_vars) {
  df[[v]] <- factor(df[[v]], ordered = FALSE)
}

# comprovar que  són factors
sapply(df[cat_vars], class)

# comprovar que la resta són enters (integer) o numèriques contínues ()
num_vars <- setdiff(names(df), cat_vars)
sapply(df[num_vars], class)


# comprovar si hi ha files amb valors buits (no n'hi ha)
n_total <- nrow(df)
cat("Files totals:", n_total, "\n")
na_per_row <- rowSums(is.na(df))
n_with_na <- sum(na_per_row > 0)
cat("Files amb almenys un NA:", n_with_na, "\n")

