from sklearn.metrics import confusion_matrix, hamming_loss


def f1_score_macro(true, pred):
    tn, fp, fn, tp = confusion_matrix(true, pred).ravel()
    return (2 * tp) / ((2 * tp) + fn + fp)


y_true = [1, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1]
y_pred = [1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 0]

y_true_1 = [1, 1, 0, 0]  # (1,0,1) (1,1,0) (0,1,1) (0,0,1)
y_pred_1 = [1, 1, 1, 0]  # (1,1,0) (1,1,0) (1,1,1) (0,1,0)
y_true_2 = [0, 1, 1, 0]
y_pred_2 = [1, 1, 1, 1]
y_true_3 = [1, 0, 1, 1]
y_pred_3 = [0, 0, 1, 0]

hamming_loss = hamming_loss(y_true, y_pred)
print("hamming_loss = {}".format(hamming_loss))

f1_score_1 = f1_score_macro(y_true_1, y_pred_1)
f1_score_2 = f1_score_macro(y_true_2, y_pred_2)
f1_score_3 = f1_score_macro(y_true_3, y_pred_3)

f1_score_macro = (f1_score_1 + f1_score_2 + f1_score_3) / 3
print("f1_score_macro = {}".format(f1_score_macro))

f1_score_micro = (2 * 5) / ((2 * 5) + 2 + 3)
print("f1_score_micro = {}".format(f1_score_micro))
