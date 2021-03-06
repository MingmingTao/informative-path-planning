#!/usr/bin/env bash
if [ ! -d experiments ]; then
mkdir experiments
fi

pushd experiments
    for seed in {0..10000..100}
    do
        for pathset in dubins
        do
            for goal_only in False 
            do
                for cost in False 
                do
                    for nonmyopic in True #False 
                    do
                        for reward_func in mes #mean 
                        do
                          for tree_type in dpw belief
                          do
                              echo sim_seed${seed}-pathset${pathset}-nonmyopic${nonmyopic}-tree${tree_type}
                              # Dont want to run either cost or goal only
                              if [ ${pathset} = dubins ] && [ ${goal_only} = True ]; then
                                  continue
                              fi
                              if [ ${pathset} = dubins ] && [ ${cost} = True ]; then
                                  continue
                              fi
                              #  Don't want to run myopic UCB
                              #if [ ${reward_func} = mean ] && [ ${nonmyopic} = False ]; then
                              #    continue
                              #fi
                              # Myopic; tree_type should be ignored anyways, but should only run once
                              if [ ${nonmyopic} = False ] && [ ${tree_type} = belief ]; then
                                  continue
                              fi


                              if [ ${pathset} = fully_reachable_goal ] && [ ${nonmyopic} = True ]; then
                                  continue
                              fi
                              # if [ ${pathset} = fully_reachable_goal ] && [ ${cost} = False ]; then
                              #     continue
                              # fi
                              # if [ ${pathset} = fully_reachable_goal ] && [ ${cost} = False ]; then
                              #     continue
                              # fi

                              if [ ${nonmyopic} = False ]; then
                                workdir=sim_seed${seed}-pathset${pathset}-nonmyopic${nonmyopic}-NOISE
                              else
                                workdir=sim_seed${seed}-pathset${pathset}-nonmyopic${nonmyopic}-tree${tree_type}-NOISE
                              fi
                              
                              if [ -d $workdir ] && [ -f ${workdir}/figures/${reward_func}/trajectory-N.SUMMARY.png ] ; then 
                                continue
                              fi

                              if [ -d $workdir ] && [ -f ${workdir}/figures/${reward_func}/trajectory-N.SUMMARY.png ] ; then 
                                continue
                              fi

                              if [ ! -d $workdir ]; then mkdir $workdir; fi

                              pushd $workdir
                              cmd="python ../../nonmyopic_experiments.py ${seed} ${reward_func} ${pathset} ${cost} ${nonmyopic} ${goal_only} ${tree_type}"
                              echo $cmd
                              $cmd
                              popd
                            done
                        done
                    done
                done
            done
        done
    done
popd
