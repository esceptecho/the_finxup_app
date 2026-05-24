enum ToleranceCase {
  monthlyBudget,
  investmentReturn,
  savingsGoal,
  paymentDate,
  roundingError,
  responseTime,
  custom;

  bool get isOverspendingCritical {
    // En presupuestos, pasarse del límite superior es malo.
    // En metas de ahorro, estar por debajo del límite inferior es lo crítico.
    return this == ToleranceCase.monthlyBudget ||
        this == ToleranceCase.roundingError;
  }

  String get displayName {
    switch (this) {
      case ToleranceCase.monthlyBudget:
        return '💰 Presupuesto mensual';
      case ToleranceCase.investmentReturn:
        return '📈 Retorno de inversión';
      case ToleranceCase.savingsGoal:
        return '🏦 Meta de ahorro';
      case ToleranceCase.paymentDate:
        return '📅 Fecha de pago';
      case ToleranceCase.roundingError:
        return '🔄 Error de redondeo';
      case ToleranceCase.responseTime:
        return '⏱️ Tiempo de respuesta';
      case ToleranceCase.custom:
        return '✏️ Personalizado';
    }
  }

  String get description {
    switch (this) {
      case ToleranceCase.monthlyBudget:
        return 'Gasto mensual planificado con margen de tolerancia';
      case ToleranceCase.investmentReturn:
        return 'Retorno esperado anual con variación permitida';
      case ToleranceCase.savingsGoal:
        return 'Cantidad ahorrada para una meta específica';
      case ToleranceCase.paymentDate:
        return 'Día del mes para realizar un pago';
      case ToleranceCase.roundingError:
        return 'Error máximo permitido en registros financieros';
      case ToleranceCase.responseTime:
        return 'Tiempo de respuesta esperado de un servicio';
      case ToleranceCase.custom:
        return 'Define tus propios valores';
    }
  }

  String get centerLabel {
    switch (this) {
      case ToleranceCase.monthlyBudget:
        return 'Gasto planificado (\$)';
      case ToleranceCase.investmentReturn:
        return 'Retorno esperado (%)';
      case ToleranceCase.savingsGoal:
        return 'Meta de ahorro (\$)';
      case ToleranceCase.paymentDate:
        return 'Día ideal de pago';
      case ToleranceCase.roundingError:
        return 'Valor real (\$)';
      case ToleranceCase.responseTime:
        return 'Tiempo esperado (minutos)';
      case ToleranceCase.custom:
        return 'Valor central';
    }
  }

  String get toleranceLabel {
    switch (this) {
      case ToleranceCase.monthlyBudget:
        return 'Tolerancia (\$)';
      case ToleranceCase.investmentReturn:
        return 'Variación permitida (%)';
      case ToleranceCase.savingsGoal:
        return 'Tolerancia (\$)';
      case ToleranceCase.paymentDate:
        return 'Días de tolerancia';
      case ToleranceCase.roundingError:
        return 'Error máximo (\$)';
      case ToleranceCase.responseTime:
        return 'Tolerancia (minutos)';
      case ToleranceCase.custom:
        return 'Tolerancia';
    }
  }

  (double, double) getDefaultValues() {
    switch (this) {
      case ToleranceCase.monthlyBudget:
        return (500, 50);
      case ToleranceCase.investmentReturn:
        return (8, 2);
      case ToleranceCase.savingsGoal:
        return (10000, 500);
      case ToleranceCase.paymentDate:
        return (15, 2);
      case ToleranceCase.roundingError:
        return (100, 0.5);
      case ToleranceCase.responseTime:
        return (2, 0.5);
      case ToleranceCase.custom:
        return (0, 0);
    }
  }
}
