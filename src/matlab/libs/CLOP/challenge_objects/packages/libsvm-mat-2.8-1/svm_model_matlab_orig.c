#include <stdlib.h>
#include <string.h>
#include "svm.h"

#include "mex.h"

#define NUM_OF_RETURN_FIELD 10

static const char *field_names[] = {
	"Parameters",
	"nr_class",
	"totalSV",
	"rho",
	"Label",
	"ProbA",
	"ProbB",
	"nSV",
	"sv_coef",
	"SVs"
};

const char *model_to_matlab_structure(mxArray *plhs[], int num_of_feature, struct svm_model *model)
{
	int i, j, n;
	double *ptr;
	mxArray *return_model, **rhs;
	int out_id = 0;

	rhs = (mxArray **)mxMalloc(sizeof(mxArray *)*NUM_OF_RETURN_FIELD);

	// Parameters
	rhs[out_id] = mxCreateDoubleMatrix(5, 1, mxREAL);
	ptr = mxGetPr(rhs[out_id]);
	ptr[0] = model->param.svm_type;
	ptr[1] = model->param.kernel_type;
	ptr[2] = model->param.degree;
	ptr[3] = model->param.gamma;
	ptr[4] = model->param.coef0;
	out_id++;

	// nr_class
	rhs[out_id] = mxCreateDoubleMatrix(1, 1, mxREAL);
	ptr = mxGetPr(rhs[out_id]);
	ptr[0] = model->nr_class;
	out_id++;

	// total SV
	rhs[out_id] = mxCreateDoubleMatrix(1, 1, mxREAL);
	ptr = mxGetPr(rhs[out_id]);
	ptr[0] = model->l;
	out_id++;

	// rho
	n = model->nr_class*(model->nr_class-1)/2;
	rhs[out_id] = mxCreateDoubleMatrix(n, 1, mxREAL);
	ptr = mxGetPr(rhs[out_id]);
	for(i = 0; i < n; i++)
		ptr[i] = model->rho[i];
	out_id++;

	// Label
	if(model->label)
	{
		rhs[out_id] = mxCreateDoubleMatrix(model->nr_class, 1, mxREAL);
		ptr = mxGetPr(rhs[out_id]);
		for(i = 0; i < model->nr_class; i++)
			ptr[i] = model->label[i];
	}
	else
		rhs[out_id] = mxCreateDoubleMatrix(0, 0, mxREAL);
	out_id++;

	// probA, probB
	if(model->probA != NULL && model->probB != NULL)
	{
		rhs[out_id] = mxCreateDoubleMatrix(n, 1, mxREAL);
		ptr = mxGetPr(rhs[out_id]);
		for(i = 0; i < n; i++)
			ptr[i] = model->probA[i];

		rhs[out_id+1] = mxCreateDoubleMatrix(n, 1, mxREAL);
		ptr = mxGetPr(rhs[out_id+1]);
		for(i = 0; i < n; i++)
			ptr[i] = model->probB[i];
	}
	else
	{
		rhs[out_id] = mxCreateDoubleMatrix(0, 0, mxREAL);
		rhs[out_id+1] = mxCreateDoubleMatrix(0, 0, mxREAL);
	}
	out_id+=2;

	// nSV
	if(model->nSV)
	{
		rhs[out_id] = mxCreateDoubleMatrix(model->nr_class, 1, mxREAL);
		ptr = mxGetPr(rhs[out_id]);
		for(i = 0; i < model->nr_class; i++)
			ptr[i] = model->nSV[i];
	}
	else
		rhs[out_id] = mxCreateDoubleMatrix(0, 0, mxREAL);
	out_id++;

	// sv_coef
	rhs[out_id] = mxCreateDoubleMatrix(model->l, model->nr_class-1, mxREAL);
	ptr = mxGetPr(rhs[out_id]);
	for(i = 0; i < model->nr_class-1; i++)
		for(j = 0; j < model->l; j++)
			ptr[(i*(model->l))+j] = model->sv_coef[i][j];
	out_id++;

	// SVs
	{
		int *ir, *jc, ir_index, nonzero_element;
		mxArray *pprhs[1], *pplhs[1];	

		nonzero_element = 0;
		for(i = 0; i < model->l; i++) {
			j = 0;
			while(model->SV[i][j].index != -1) {
				nonzero_element++;
				j++;
			}
		}

		// SV in column, easier accessing
		rhs[out_id] = mxCreateSparse(num_of_feature, model->l, nonzero_element, mxREAL);
		ir = mxGetIr(rhs[out_id]);
		jc = mxGetJc(rhs[out_id]);
		ptr = mxGetPr(rhs[out_id]);
		ir_index = jc[0] = 0;
		for(i = 0;i < model->l; i++)
		{
			int x_index = 0;
			while (model->SV[i][x_index].index != -1)
			{
				ir[ir_index] = model->SV[i][x_index].index - 1; 
				ptr[ir_index] = model->SV[i][x_index].value;
				ir_index++, x_index++;
			}
			jc[i+1] = jc[i] + x_index;
		}
		// transpose back to SV in row
		pprhs[0] = rhs[out_id];
		if (mexCallMATLAB(1, pplhs, 1, pprhs, "transpose"))
			return "cannot transpose SV matrix";
		rhs[out_id] = pplhs[0];
		out_id++;
	}

	/* Create a struct matrix contains NUM_OF_RETURN_FIELD fields */
	return_model = mxCreateStructMatrix(1, 1, NUM_OF_RETURN_FIELD, field_names);

	/* Fill struct matrix with input arguments */
	for(i = 0; i < NUM_OF_RETURN_FIELD; i++)
		mxSetField(return_model,0,field_names[i],mxDuplicateArray(rhs[i]));
	/* return */
	plhs[0] = return_model;
	mxFree(rhs);

	return NULL;
}

const char *matlab_matrix_to_model(struct svm_model *model, const mxArray *matlab_struct)
{
	int i, j, n, num_of_fields;
	double *ptr;
	int id = 0;
	struct svm_node *x_space;
	mxArray **rhs;

	num_of_fields = mxGetNumberOfFields(matlab_struct);
	rhs = (mxArray **) mxMalloc(sizeof(mxArray *)*num_of_fields);

	for(i=0;i<num_of_fields;i++)
		rhs[i] = mxGetFieldByNumber(matlab_struct, 0, i);

	model->rho = NULL;
	model->probA = NULL;
	model->probB = NULL;
	model->label = NULL;
	model->nSV = NULL;
	model->free_sv = 1; // XXX

	ptr = mxGetPr(rhs[id]);
	model->param.svm_type	  = (int)ptr[0];
	model->param.kernel_type  = (int)ptr[1];
	model->param.degree	  = ptr[2];
	model->param.gamma	  = ptr[3];
	model->param.coef0	  = ptr[4];
	id++;

	ptr = mxGetPr(rhs[id]);
	model->nr_class = (int)ptr[0];
	id++;

	ptr = mxGetPr(rhs[id]);
	model->l = (int)ptr[0];
	id++;

	// rho
	n = model->nr_class * (model->nr_class-1)/2;
	model->rho = (double*) malloc(n*sizeof(double));
	ptr = mxGetPr(rhs[id]);
	for(i=0;i<n;i++)
		model->rho[i] = ptr[i];
	id++;

	// label
	if (mxIsEmpty(rhs[id]) == 0)
	{
		model->label = (int*) malloc(model->nr_class*sizeof(int));
		ptr = mxGetPr(rhs[id]);
		for(i=0;i<model->nr_class;i++)
			model->label[i] = (int)ptr[i];
	}
	id++;

	// probA, probB
	if(mxIsEmpty(rhs[id]) == 0 &&
	   mxIsEmpty(rhs[id+1]) == 0)
	{
		model->probA = (double*) malloc(n*sizeof(double));
		model->probB = (double*) malloc(n*sizeof(double));
		ptr = mxGetPr(rhs[id]);
		for(i=0;i<n;i++)
			model->probA[i] = ptr[i];
		ptr = mxGetPr(rhs[id+1]);
		for(i=0;i<n;i++)
			model->probB[i] = ptr[i];
	}
	id += 2;

	// nSV
	if (mxIsEmpty(rhs[id]) == 0)
	{
		model->nSV = (int*) malloc(model->nr_class*sizeof(int));
		ptr = mxGetPr(rhs[id]);
		for(i=0;i<model->nr_class;i++)
			model->nSV[i] = (int)ptr[i];
	}
	id++;

	// sv_coef
	ptr = mxGetPr(rhs[id]);
	model->sv_coef = (double**) malloc((model->nr_class-1)*sizeof(double));
	for( i=0 ; i< model->nr_class -1 ; i++ )
		model->sv_coef[i] = (double*) malloc((model->l)*sizeof(double));
	for(i = 0; i < model->nr_class - 1; i++)
		for(j = 0; j < model->l; j++)
			model->sv_coef[i][j] = ptr[i*(model->l)+j];
	id++;

	// SV
	{
		int sr, sc, elements;
		int num_samples;
		int *ir, *jc;
		mxArray *pprhs[1], *pplhs[1];

		// transpose SV
		pprhs[0] = rhs[id];
		if (mexCallMATLAB(1, pplhs, 1, pprhs, "transpose"))
			return "cannot transpose SV matrix";
		rhs[id] = pplhs[0];

		sr = mxGetN(rhs[id]);
		sc = mxGetM(rhs[id]);

		ptr = mxGetPr(rhs[id]);
		ir = mxGetIr(rhs[id]);
		jc = mxGetJc(rhs[id]);

		num_samples = mxGetNzmax(rhs[id]);

		elements = num_samples + sr;

		model->SV = (struct svm_node **) malloc(sr * sizeof(struct svm_node *));
		x_space = (struct svm_node *)malloc(elements * sizeof(struct svm_node));

		// SV is in column
		for(i=0;i<sr;i++)
		{
			int low = jc[i], high = jc[i+1];
			int x_index = 0;
			model->SV[i] = &x_space[low+i];
			for(j=low;j<high;j++)
			{
				model->SV[i][x_index].index = ir[j] + 1; 
				model->SV[i][x_index].value = ptr[j];
				x_index++;
			}
			model->SV[i][x_index].index = -1;
		}

		id++;
	}
	mxFree(rhs);

	return NULL;
}
