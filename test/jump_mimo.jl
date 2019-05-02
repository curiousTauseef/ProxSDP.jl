function jump_mimo(solver, seed, n, verbose = false, test = false)

    # n = 3
    m = 10n
    s, H, y, L = mimo_data(seed, m, n)

    nvars = ProxSDP.sympackedlen(n + 1)

    model = Model(with_optimizer(solver))
    @variable(model, X[1:n+1, 1:n+1], PSD)
    for i in 1:(n+1), j in i:(n+1)
        @constraint(model, X[i, j] <=  1.0)
        @constraint(model, X[i, j] >= -1.0)
    end
    @objective(model, Min, sum(L[i, j] * X[i, j] for i in 1:n+1, j in 1:n+1))
    @constraint(model, ctr[i in 1:n+1], X[i, i] == 1.0)
    
    @time teste = optimize!(model)

    XX = value.(X)

    if test
        for i in 1:n+1, j in 1:n+1
            @test 1.01> abs(XX[i,j]) > 0.99
        end
    end

    verbose && mimo_eval(s,H,y,L,XX)

    return nothing
end
