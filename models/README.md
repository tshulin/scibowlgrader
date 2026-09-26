# Models

Qwen3.5-0.8B Science Bowl answer graders. Names follow
`scibowlgrader_qwen3_5_0_8b_model_<training set>_<form>`.

| Folder | What it is | Benchmark v2 (all 3,653 rows) |
|---|---|---|
| `scibowlgrader_qwen3_5_0_8b_model_f_int4` | **Recommended.** Training set F, merged, INT4 W4A16 (GPTQ) | 97.4 % |
| `scibowlgrader_qwen3_5_0_8b_model_f_fp8` | Training set F, merged, FP8 (FP8_DYNAMIC, stored checkpoint) | 96.8 % |
| `scibowlgrader_qwen3_5_0_8b_model_f_bf16` | Training set F, merged, bf16 | 97.5 % |
| `scibowlgrader_qwen3_5_0_8b_model_f_lora` | Training set F, LoRA adapter (r=16, α=32) | 97.5 % (merged bf16) |
| `scibowlgrader_qwen3_5_0_8b_model_e_lora` | Training set E, LoRA adapter (r=16, α=32) | 86.7 % |
| `scibowlgrader_qwen3_5_0_8b_model_c_lora` | Training set C, LoRA adapter (r=32, α=64) | 88.8 % |
| `scibowlgrader_qwen3_5_0_8b_model_b_lora` | Training set B, LoRA adapter (r=32, α=64) | 90.7 % |

LoRA scores are for the adapter merged onto `Qwen/Qwen3.5-0.8B` in bf16. The FP8 folder is a stored
checkpoint; loading the bf16 model with vLLM's `quantization="fp8"` instead scored 97.4 %.

## Using them

The merged models (`_bf16`, `_fp8`, `_int4`) store `model.safetensors` as 95 MiB pieces. Rebuild once
after cloning (checks each file's sha256):

```bash
bash models/reassemble.sh
```

Then load a folder directly, e.g. with vLLM:

```python
from vllm import LLM
llm = LLM(model="models/scibowlgrader_qwen3_5_0_8b_model_f_int4")
```

Prompt: the `prompt_v1` template, rendered with the model's chat template and thinking off; the
model answers with one token, `CORRECT` or `INCORRECT`. Training rows in `training_data/` show the
exact text.

LoRA adapters load on top of `Qwen/Qwen3.5-0.8B`. Their `adapter_config.json` names the base as
`togethercomputer/Qwen3.5-0.8B`, a mirror; point PEFT at `Qwen/Qwen3.5-0.8B`. The adapter keys target
`Qwen3_5ForConditionalGeneration` (`model.language_model.layers.N`), so load the base with that class.
