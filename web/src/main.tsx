import { zodResolver } from "@hookform/resolvers/zod";
import {
  Alert,
  Box,
  Button,
  Card,
  CardActions,
  CardContent,
  CircularProgress,
  Container,
  CssBaseline,
  Divider,
  Stack,
  TextField,
  ThemeProvider,
  Typography,
  createTheme
} from "@mui/material";
import React, { useEffect, useState } from "react";
import { createRoot } from "react-dom/client";
import { useForm } from "react-hook-form";
import { z } from "zod";

import { PqRequest, PqResponse, ProblemDetail, createPq, deletePq, fetchPq, isProblemDetail, updatePq } from "./api";

const theme = createTheme();

const pqSchema = z.object({
  firstName: z
    .string()
    .trim()
    .min(1, "First name is required")
    .max(100, "First name must be at most 100 characters"),
  lastName: z
    .string()
    .trim()
    .min(1, "Last name is required")
    .max(100, "Last name must be at most 100 characters"),
  dob: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, "Use format YYYY-MM-DD"),
  ssn: z
    .string()
    .min(9, "SSN must contain 9 digits")
    .max(11, "SSN must contain 9 digits")
    .refine((val) => val.replace(/\D/g, "").length === 9, "SSN must contain exactly 9 digits")
});

type PqFormValues = z.infer<typeof pqSchema>;

const emptyForm: PqFormValues = { firstName: "", lastName: "", dob: "", ssn: "" };

const App = () => {
  const [record, setRecord] = useState<PqResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const [serverError, setServerError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors },
    setError,
    reset
  } = useForm<PqFormValues>({
    resolver: zodResolver(pqSchema),
    defaultValues: emptyForm
  });

  useEffect(() => {
    const load = async () => {
      setLoading(true);
      try {
        const existing = await fetchPq();
        setRecord(existing);
        reset(existing ? { firstName: existing.firstName, lastName: existing.lastName, dob: existing.dob, ssn: "" } : emptyForm);
        setServerError(null);
      } catch (err) {
        setServerError("Failed to load PQ. Please try again.");
      } finally {
        setLoading(false);
      }
    };
    load();
  }, [reset]);

  const applyProblemErrors = (problem: ProblemDetail) => {
    if (problem.fieldErrors) {
      Object.entries(problem.fieldErrors).forEach(([field, messages]) => {
        const message = messages.join(" ");
        if (["firstName", "lastName", "dob", "ssn"].includes(field)) {
          setError(field as keyof PqFormValues, { type: "server", message });
        }
      });
    }
    setServerError(problem.detail ?? problem.title);
  };

  const onSubmit = async (values: PqFormValues) => {
    setSaving(true);
    setServerError(null);
    try {
      const payload: PqRequest = {
        firstName: values.firstName.trim(),
        lastName: values.lastName.trim(),
        dob: values.dob,
        ssn: values.ssn.replace(/\D/g, "")
      };
      const response = record ? await updatePq(payload) : await createPq(payload);
      setRecord(response);
      reset({ firstName: response.firstName, lastName: response.lastName, dob: response.dob, ssn: "" });
    } catch (err) {
      if (isProblemDetail(err)) {
        applyProblemErrors(err);
      } else if (err instanceof Error && err.message === "not-found") {
        setServerError("No PQ exists for this prospect.");
      } else {
        setServerError("Unable to save PQ. Please try again.");
      }
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!record) return;
    setDeleting(true);
    setServerError(null);
    try {
      await deletePq();
      setRecord(null);
      reset(emptyForm);
    } catch (err) {
      if (isProblemDetail(err)) {
        applyProblemErrors(err);
      } else {
        setServerError("Unable to delete PQ. Please try again.");
      }
    } finally {
      setDeleting(false);
    }
  };

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Container maxWidth="sm" sx={{ py: 6 }}>
        <Stack spacing={3}>
          <Box>
            <Typography variant="h4" gutterBottom>
              Prospect PQ
            </Typography>
            <Typography variant="body1" color="text.secondary">
              Create, update, or delete your pre-qualification record. SSN is required for save operations and is stored encrypted; only the last four
              digits are shown after saving.
            </Typography>
          </Box>

          {serverError && <Alert severity="error">{serverError}</Alert>}

          <Card>
            <CardContent>
              <Stack spacing={2}>
                <Typography variant="h6">Current status</Typography>
                {loading ? (
                  <Box display="flex" justifyContent="center" py={2}>
                    <CircularProgress size={28} />
                  </Box>
                ) : record ? (
                  <Box>
                    <Typography variant="body1">
                      <strong>Name:</strong> {record.firstName} {record.lastName}
                    </Typography>
                    <Typography variant="body1">
                      <strong>Date of birth:</strong> {record.dob}
                    </Typography>
                    <Typography variant="body1">
                      <strong>SSN last 4:</strong> ****{record.ssnLast4}
                    </Typography>
                  </Box>
                ) : (
                  <Typography variant="body1" color="text.secondary">
                    No PQ saved yet.
                  </Typography>
                )}

                <Divider />

                <Box component="form" noValidate onSubmit={handleSubmit(onSubmit)}>
                  <Stack spacing={2}>
                    <TextField
                      label="First name"
                      fullWidth
                      disabled={saving || loading}
                      error={!!errors.firstName}
                      helperText={errors.firstName?.message}
                      {...register("firstName")}
                    />
                    <TextField
                      label="Last name"
                      fullWidth
                      disabled={saving || loading}
                      error={!!errors.lastName}
                      helperText={errors.lastName?.message}
                      {...register("lastName")}
                    />
                    <TextField
                      label="Date of birth"
                      type="date"
                      fullWidth
                      InputLabelProps={{ shrink: true }}
                      disabled={saving || loading}
                      error={!!errors.dob}
                      helperText={errors.dob?.message || "Format: YYYY-MM-DD"}
                      {...register("dob")}
                    />
                    <TextField
                      label="Social Security number"
                      fullWidth
                      disabled={saving || loading}
                      error={!!errors.ssn}
                      helperText={errors.ssn?.message || "Enter the full 9-digit SSN (digits only)."}
                      inputProps={{ inputMode: "numeric" }}
                      {...register("ssn")}
                    />

                    <CardActions sx={{ px: 0 }}>
                      <Button type="submit" variant="contained" disabled={saving || loading}>
                        {saving ? "Saving..." : record ? "Save changes" : "Create PQ"}
                      </Button>
                      <Button color="error" onClick={handleDelete} disabled={!record || deleting || loading}>
                        {deleting ? "Deleting..." : "Delete PQ"}
                      </Button>
                    </CardActions>
                  </Stack>
                </Box>
              </Stack>
            </CardContent>
          </Card>
        </Stack>
      </Container>
    </ThemeProvider>
  );
};

const root = document.getElementById("root");
if (root) {
  createRoot(root).render(
    <React.StrictMode>
      <App />
    </React.StrictMode>
  );
}
